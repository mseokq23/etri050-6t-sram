#!/usr/bin/env python3
"""Make the macro's extracted netlist (layout/sram64x4_pex.spice, etri-pex) usable by gen_tb.py.

  python3 ../scripts/pex_for_sim.py ../layout/sram64x4_pex.spice -o sram64x4_pex.spice

  - pins A[0] -> A_0 (ngspice reads [ ] in .control as a vector index)
  - the nodes gen_tb.py --probe looks at get the schematic names:
      wl_0 .. wl_15 : output of the row driver whose NAND gate sees P0[r % 4] and P1[r // 4]
      sae, pre_n    : control block outputs
      dl_0, dlb_0   : bit 0 data lines (drains of the write driver transistors on DQB[0] / DQ[0])
"""
import argparse
import re

ap = argparse.ArgumentParser()
ap.add_argument("pex")
ap.add_argument("-o", default="sram64x4_pex.spice")
args = ap.parse_args()

text = open(args.pex).read()
devs = [ln.split()[1:6] for ln in text.split("\n") if ln.startswith("M")]   # d g s b model

rename = {"sram64x4_ctrl_0/SAE": "sae", "sram64x4_ctrl_0/PRE_N": "pre_n"}

# row drivers: rowdec_0/rowdrv_x2_K/rowdrv_M/<NAND output> drives the inverter whose output is the WL
nand_in, wl_of = {}, {}
for d, g, s, b, model in devs:
    m = re.match(r"(rowdec_0/rowdrv_x2_\d+/rowdrv_\d+)/", d)
    p = re.match(r"sram64x4_ctrl_0/P([01])\[(\d)\]$", g)
    if m and p:
        nand_in.setdefault(m.group(1), {})[p.group(1)] = int(p.group(2))
for d, g, s, b, model in devs:
    m = re.match(r"(rowdec_0/rowdrv_x2_\d+/rowdrv_\d+)/", g)
    if m:
        for n in (d, s):
            if n.endswith("/WL"):
                wl_of[m.group(1)] = n
for drv, sel in nand_in.items():
    rename[wl_of[drv]] = f"wl_{sel['0'] + 4 * sel['1']}"

# write driver of bit 0 (sim/periph.spice wdrv): DL - [WDEN] - N1 - [DQB] - VSS, DLB - [WDEN] - N2 - [DQ] - VSS
for d, g, s, b, model in devs:
    if model == "nfet" and g in ("sram64x4_ctrl_0/DQB[0]", "sram64x4_ctrl_0/DQ[0]"):
        n1 = s if d == "VSS" else d
        for d2, g2, s2, b2, model2 in devs:
            if g2 == "sram64x4_ctrl_0/WDEN" and n1 in (d2, s2):
                rename[s2 if d2 == n1 else d2] = "dl_0" if g.endswith("DQB[0]") else "dlb_0"

names = sorted(set(rename.values()))
want = [f"wl_{r}" for r in range(16)] + ["sae", "pre_n", "dl_0", "dlb_0"]
missing = [w for w in want if w not in names]
if missing:
    raise SystemExit(f"not found: {missing}")


def sub(m):
    return rename.get(m.group(0), m.group(0))


out = []
for ln in text.split("\n"):
    ln = re.sub(r"\S+", sub, ln) if (ln.startswith("M") or ln.startswith("C") or ln.startswith("+")) else ln
    out.append(ln)
text = "\n".join(out)
text = re.sub(r"\[(\d+)\]", r"_\1", text)
open(args.o, "w").write(text)
print(f"wrote {args.o}: {len(devs)} transistors, {text.count(chr(10) + 'C')} capacitors, "
      f"probe nodes {' '.join(want)}")
