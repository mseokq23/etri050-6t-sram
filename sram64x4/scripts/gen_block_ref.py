#!/usr/bin/env python3
"""LVS reference netlists of the blocks (layout/lvs_<block>.tcl makes the matching <block>_lvs cells).

  python3 ../scripts/gen_block_ref.py      (in sram64x4/layout)
    -> rowdec_lvs_ref.spice, colperi_lvs_ref.spice, sabank_lvs_ref.spice
  each = sim/periph.spice + one subcircuit with the block's instances, bus bits written A[0]
"""
import os

S = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
periph = open(os.path.join(S, "sim", "periph.spice")).read()


def bus(name, n):
    return [f"{name}[{i}]" for i in range(n)]


blocks = {
    "rowdec_lvs": (bus("P0", 4) + bus("P1", 4) + bus("WL", 16) + ["VDD", "VSS"],
                   [f"XR{r} P0[{r % 4}] P1[{r // 4}] WL[{r}] VDD VSS rowdrv" for r in range(16)]),
    "colperi_lvs": (bus("BL", 16) + bus("BLB", 16) + bus("DL", 4) + bus("DLB", 4) + bus("MUX", 4) +
                    ["PRE_N", "VDD", "VSS"],
                    [f"XPC{c} BL[{c}] BLB[{c}] PRE_N VDD pchg" for c in range(16)] +
                    [f"XMX{c} BL[{c}] BLB[{c}] DL[{c // 4}] DLB[{c // 4}] MUX[{c % 4}] VSS cmux" for c in range(16)]),
    "sabank_lvs": (bus("DL", 4) + bus("DLB", 4) + ["SAE", "WDEN", "PRE_N"] + bus("SAO", 4) + bus("DQ", 4) +
                   bus("DQB", 4) + ["VDD", "VSS"],
                   [f"XSA{b} DL[{b}] DLB[{b}] SAE PRE_N SAO[{b}] VDD VSS sa" for b in range(4)] +
                   [f"XWD{b} DL[{b}] DLB[{b}] WDEN DQ[{b}] DQB[{b}] VSS wdrv" for b in range(4)]),
}
for name, (pins, inst) in blocks.items():
    with open(f"{name}_ref.spice", "w") as fo:
        fo.write(periph + "\n")
        fo.write(f"* {name.replace('_lvs', '')} block (written by scripts/gen_block_ref.py)\n")
        fo.write(f".subckt {name} " + " ".join(pins) + "\n" + "\n".join(inst) + "\n.ends\n.end\n")
    print(f"{name}_ref.spice: {len(inst)} instances, {len(pins)} pins")
