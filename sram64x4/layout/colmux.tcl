# one column below the array: bit-line precharge (PMOS) + column mux (NMOS), pitch 60 lambda
#   y = 0 is the bottom end of the array's bit lines, everything goes down from there
#   BL metal2 x 1..5, BLB metal2 x 49..53 (same as the cell)
#   PRE_N: horizontal poly through all columns (y -19..-17)
#   MUX gate: poly x 6..48 y -49..-47, contact x 24..30 -> via at y -60..-53 (tapped to MUX[k] by colperi.tcl)
#   DL / DLB leave on vias at y -60..-53 (x 1..8 / 46..53), continued down by colperi.tcl
#   (Magic console, in the layout folder: source colmux.tcl)
source common.tcl
snap lambda
newcell colmux

# precharge PMOS: BL -> VDD, BLB -> VDD
box 0 -33 60 -3;     paint nwell
box 0 -15 60 -9;     paint metal1
box 8 -27 20 -9;     paint pdiffusion
box 34 -27 46 -9;    paint pdiffusion
box 0 -19 60 -17;    paint polysilicon
box 8 -15 20 -9;     paint pdcontact
box 34 -15 46 -9;    paint pdcontact
box 8 -27 20 -21;    paint pdcontact
box 34 -27 46 -21;   paint pdcontact
box 24 -15 30 -9;    paint nsubstratencontact

# column mux NMOS: BL -> DL, BLB -> DLB
box 8 -57 20 -39;    paint ndiffusion
box 34 -57 46 -39;   paint ndiffusion
box 6 -49 48 -47;    paint polysilicon
box 24 -51 30 -45;   paint polycontact
box 8 -45 20 -39;    paint ndcontact
box 34 -45 46 -39;   paint ndcontact
box 8 -57 20 -51;    paint ndcontact
box 34 -57 46 -51;   paint ndcontact

# BL / BLB nodes: precharge drain + mux drain, via to the bit line
box 8 -39 20 -27;    paint metal1
box 34 -39 46 -27;   paint metal1
box 1 -32 20 -25;    paint metal1
box 1 -32 8 -25;     paint m2contact
box 1 -32 5 0;       paint metal2
box 34 -32 53 -25;   paint metal1
box 46 -32 53 -25;   paint m2contact
box 49 -32 53 0;     paint metal2

# DL / DLB side of the mux and the gate contact -> vias
box 1 -60 20 -53;    paint metal1
box 1 -60 8 -53;     paint m2contact
box 34 -60 53 -53;   paint metal1
box 46 -60 53 -53;   paint m2contact
box 24 -53 30 -51;   paint metal1
box 24 -60 31 -53;   paint m2contact

box 0 -60 60 0
save colmux
