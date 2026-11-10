#!/usr/bin/env python3
"""Write the schematic-level netlist of the sram64x4 macro (sim/sram64x4.spice).

  16 x 16 sram6t array, 16 row drivers, 16 precharge + mux columns,
  4 sense amps + 4 write drivers, control block (sim/sram64x4_ctrl.spice from rtl/ via vlog2Spice)

  row r = A[3:0], bit b uses columns 4b..4b+3, column 4b+c is selected by MUX[c] (c = A[5:4])
  wire load from the part 1 extraction: 4 fF per cell on BL / BLB, 1.2 fF per cell on WL,
  15 - 20 fF guesses on the long control lines and 10 fF on DL / DLB
  bus bits are written A_0 (ngspice) or A[0] (--lvs)
"""
import argparse

ap = argparse.ArgumentParser()
ap.add_argument("-o", default="sram64x4.spice")
ap.add_argument("--no-wire", action="store_true", help="leave out the wire capacitors")
ap.add_argument("--lvs", action="store_true", help="bus names A[0] (LVS) instead of A_0 (ngspice)")
args = ap.parse_args()

ROWS, COLS, BITS = 16, 16, 4
pins = ["VDD", "VSS", "CLK", "WE"] + [f"A[{i}]" for i in range(6)] + \
       [f"DIN[{i}]" for i in range(4)] + [f"DOUT[{i}]" for i in range(4)]
L = ["* sram64x4 macro, schematic level (written by scripts/gen_macro_spice.py)",
     ".subckt sram64x4 " + " ".join(pins)]
ctrl = ["VDD", "VSS", "CLK", "WE"] + [f"A[{i}]" for i in range(6)] + [f"DIN[{i}]" for i in range(4)] + \
       [f"SAO[{i}]" for i in range(4)] + [f"DOUT[{i}]" for i in range(4)] + \
       [f"P0[{i}]" for i in range(4)] + [f"P1[{i}]" for i in range(4)] + \
       [f"MUX[{i}]" for i in range(4)] + ["PRE_N", "SAE", "WDEN"] + \
       [f"DQ[{i}]" for i in range(4)] + [f"DQB[{i}]" for i in range(4)]
L.append("XCTRL " + " ".join(ctrl) + " sram64x4_ctrl")
for r in range(ROWS):
    L.append(f"XRD{r} P0[{r % 4}] P1[{r // 4}] WL[{r}] VDD VSS rowdrv")
for c in range(COLS):
    b, k = divmod(c, 4)
    L.append(f"XPC{c} BL[{c}] BLB[{c}] PRE_N VDD pchg")
    L.append(f"XMX{c} BL[{c}] BLB[{c}] DL[{b}] DLB[{b}] MUX[{k}] VSS cmux")
for b in range(BITS):
    L.append(f"XSA{b} DL[{b}] DLB[{b}] SAE PRE_N SAO[{b}] VDD VSS sa")
    L.append(f"XWD{b} DL[{b}] DLB[{b}] WDEN DQ[{b}] DQB[{b}] VSS wdrv")
for r in range(ROWS):
    for c in range(COLS):
        L.append(f"XC{r}_{c} BL[{c}] BLB[{c}] WL[{r}] VDD VSS sram6t")
if not args.no_wire:
    for c in range(COLS):
        L.append(f"CBL{c} BL[{c}] VSS {ROWS * 4}f")
        L.append(f"CBLB{c} BLB[{c}] VSS {ROWS * 4}f")
    for r in range(ROWS):
        L.append(f"CWL{r} WL[{r}] VSS {COLS * 1.2:.1f}f")
    # long control lines (rough guess, the extraction in part 4 gives the real values)
    for n in [f"P0[{i}]" for i in range(4)] + [f"P1[{i}]" for i in range(4)] + \
             [f"MUX[{i}]" for i in range(4)] + ["SAE", "WDEN"]:
        L.append(f"CW_{n.replace('[', '').replace(']', '')} {n} VSS 15f")
    L.append("CW_PRE_N PRE_N VSS 20f")
    for b in range(BITS):
        L.append(f"CDL{b} DL[{b}] VSS 10f")
        L.append(f"CDLB{b} DLB[{b}] VSS 10f")
L.append(".ends")
text = "\n".join(L) + "\n"
if not args.lvs:   # ngspice reads v(A[0]) in .control as a vector index, so simulation netlists use A_0
    import re
    text = re.sub(r"\[(\d+)\]", r"_\1", text)
open(args.o, "w").write(text)
print(f"wrote {args.o}: {ROWS * COLS} cells, {ROWS} row drivers, {COLS} columns, {BITS} sense amps")
