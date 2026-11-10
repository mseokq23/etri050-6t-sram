#!/usr/bin/env python3
"""Gate-level Verilog (kit standard cells, named port connections) -> SPICE subcircuit.

  python3 v2spice.py <file.v> -l <standard-cell .spice> -o <out.spice> [--inline] [--underscore]
    --inline      copy the standard-cell netlist into the output (default: .include it)
    --underscore  bus bits A[0] -> A_0 (ngspice reads [ ] in .control as a vector index)

  Used in place of qflow's vlog2Spice: with some environments (the size of the environment variables)
  vlog2Spice wrote wrong bus indices (A[-80] ...) for a few instances, so the same file gave a
  different netlist in a different terminal. This script only handles what rtl/sram64x4_ctrl.v uses:
  one module, ports declared in the header, instances like  CELL name (.PIN(net), ...);
"""
import argparse
import re
import sys

ap = argparse.ArgumentParser()
ap.add_argument("verilog")
ap.add_argument("-l", "--lib", required=True)
ap.add_argument("-o", "--out", required=True)
ap.add_argument("--inline", action="store_true")
ap.add_argument("--underscore", action="store_true")
args = ap.parse_args()

# ---- standard cells: pin order of each .subckt
lib_text = open(args.lib).read()
pins_of = {}
lines = lib_text.split("\n")
for i, ln in enumerate(lines):
    if ln.lower().startswith(".subckt"):
        words = ln.split()[1:]
        j = i + 1
        while j < len(lines) and lines[j].startswith("+"):
            words += lines[j][1:].split()
            j += 1
        pins_of[words[0]] = words[1:]

# ---- Verilog
src = open(args.verilog).read()
src = re.sub(r"//[^\n]*", "", src)
src = re.sub(r"/\*.*?\*/", "", src, flags=re.S)
m = re.search(r"\bmodule\s+(\w+)\s*\((.*?)\)\s*;", src, re.S)
if not m:
    sys.exit("no module header")
module, header = m.group(1), m.group(2)
ports = []
for d in re.finditer(r"\b(?:input|output|inout)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*(\w+)", header):
    msb, lsb, name = d.group(1), d.group(2), d.group(3)
    if msb is None:
        ports.append(name)
    else:
        lo, hi = sorted((int(msb), int(lsb)))
        ports += [f"{name}[{k}]" for k in range(lo, hi + 1)]

body = src[m.end():src.find("endmodule")]
insts = []
for im in re.finditer(r"\b(\w+)\s+(\w+)\s*\((.*?)\)\s*;", body, re.S):
    cell, name, conns = im.groups()
    if cell in ("wire", "input", "output", "inout", "reg", "assign"):
        continue
    if cell not in pins_of:
        sys.exit(f"{name}: cell {cell} is not in {args.lib}")
    conn = dict(re.findall(r"\.(\w+)\s*\(\s*([\w\[\]]+)\s*\)", conns))
    missing = [p for p in pins_of[cell] if p not in conn]
    extra = [p for p in conn if p not in pins_of[cell]]
    if missing or extra:
        sys.exit(f"{name} ({cell}): pins missing {missing}, unknown {extra}")
    insts.append(f"X{name} " + " ".join(conn[p] for p in pins_of[cell]) + f" {cell}")

out = [f"* {module}: {args.verilog} -> SPICE (scripts/v2spice.py)"]
if args.inline:
    out += [ln for ln in lines if ln.strip().lower() != ".end"]
else:
    out.append(f".include {args.lib}")
top = [f".subckt {module} " + " ".join(ports)] + insts + [".ends"]
if args.underscore:
    top = [re.sub(r"\[(\d+)\]", r"_\1", t) for t in top]
out += top + [".end"]
open(args.out, "w").write("\n".join(out) + "\n")
print(f"{args.out}: {module}, {len(ports)} pins, {len(insts)} instances")
