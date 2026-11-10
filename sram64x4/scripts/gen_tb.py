#!/usr/bin/env python3
"""Write a macro testbench: write a set of words, then read them back.

  python3 ../scripts/gen_tb.py [-T 50] [--set all|rowcol] [--corner TT] [--vdd 5] [-o macro_tb.spice]
    --set all    : all 64 addresses (default)
    --set rowcol : 16 addresses, row r with column r % 4 (every row and every column once)
    --netlist    : macro netlist to include (default sram64x4.spice, the schematic-level one)
    --probe      : also save word lines, SAE, PRE_N and DL[0] / DLB[0] (schematic netlist only)
  data written to address a = (5*a + 3) & 0xF; inputs change 10 ns after the CLK falling edge
"""
import argparse, re

ap = argparse.ArgumentParser()
ap.add_argument("-T", type=float, default=50.0, help="clock period [ns]")
ap.add_argument("-o", default="macro_tb.spice")
ap.add_argument("--out", default=None, help="wrdata file (default: <deck>_out.txt)")
ap.add_argument("--netlist", default="sram64x4.spice")
ap.add_argument("--set", default="all", choices=["all", "rowcol"])
ap.add_argument("--corner", default=None, help="TT SS FF SF FS (kit corner file, see corner_lib.sh)")
ap.add_argument("--vdd", type=float, default=5.0)
ap.add_argument("--probe", action="store_true")
args = ap.parse_args()

addrs = list(range(64)) if args.set == "all" else [r + 16 * (r % 4) for r in range(16)]
T, V = args.T, args.vdd
out = args.out or args.o.replace(".spice", "_out.txt")
data = lambda a: (5 * a + 3) & 0xF
ops = [("W", a) for a in addrs] + [("R", a) for a in addrs]
tr = 0.2

def pwl(bitfun):
    pts, v_prev = [], None
    for i, op in enumerate(ops):
        v = V * bitfun(op)
        if i == 0:
            pts = [(0.0, v)]
        elif v != v_prev:
            t = i * T + 10.0          # 10 ns after the falling edge that ends cycle i-1
            pts += [(t, v_prev), (t + tr, v)]
        v_prev = v
    return "PWL(" + " ".join(f"{t:.2f}n {v:g}" for t, v in pts) + ")"

# pin order of the macro subcircuit in the netlist (schematic or extracted)
text = open(args.netlist).read()
m = re.search(r"^\.subckt\s+sram64x4\s+(.*?)\n(?!\+)", text, re.M | re.S | re.I)
pins = m.group(1).replace("\n+", " ").split()
node = {"VDD": "vdd", "VSS": "0", "CLK": "clk", "WE": "we"}
for i in range(6):
    node[f"A_{i}"] = node[f"A[{i}]"] = f"a{i}"
for i in range(4):
    node[f"DIN_{i}"] = node[f"DIN[{i}]"] = f"din{i}"
    node[f"DOUT_{i}"] = node[f"DOUT[{i}]"] = f"dout{i}"

model = (f".lib ../work/corner.lib {args.corner}" if args.corner else
         ".include ../../.pdk/ETRI050_DesignKit/spice/05cmos_model_240201.lib")
L = [f"* sram64x4 testbench: write {len(addrs)} words, read them back "
     f"(T = {T:g} ns, VDD = {V:g} V, {args.corner or 'nominal model'})",
     model,
     ".include ../../sim/sram6t_cell.spice",
     ".include periph.spice",
     ".include sram64x4_ctrl.spice",
     f".include {args.netlist}",
     f"VDD vdd 0 {V:g}",
     f"VCLK clk 0 PULSE(0 {V:g} {T/2:g}n {tr}n {tr}n {T/2 - tr:g}n {T:g}n)",
     "VWE we 0 " + pwl(lambda op: op[0] == "W")]
for i in range(6):
    L.append(f"VA{i} a{i} 0 " + pwl(lambda op, i=i: (op[1] >> i) & 1))
for i in range(4):
    L.append(f"VD{i} din{i} 0 " + pwl(lambda op, i=i: (data(op[1]) >> i) & 1))
L.append("XM " + " ".join(node[p] for p in pins) + " sram64x4")
probes = ""
if args.probe:
    probes = " " + " ".join(f"v(xm.wl_{r})" for r in range(16)) + \
             " v(xm.sae) v(xm.pre_n) v(xm.dl_0) v(xm.dlb_0)"
tstop = len(ops) * T + T / 2 + 5
L += [".control", "set wr_singlescale", f"tran 0.05n {tstop:g}n",
      f"wrdata {out} v(clk) v(we) v(dout0) v(dout1) v(dout2) v(dout3){probes}",
      ".endc", ".end"]
open(args.o, "w").write("\n".join(L) + "\n")
print(f"wrote {args.o}: {len(ops)} cycles ({args.set}), tstop {tstop:g} ns, output {out}")
