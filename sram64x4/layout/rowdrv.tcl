# row driver: NAND2 (P0, P1) + 2-finger inverter -> WL, pitch-matched to one array row (59 lambda)
#   x 0..149, y 0..59, VSS rail at the bottom, VDD rail at the top (same height as the array rails)
#   gate inputs: A (P0) contact at x 2..8 y 24..30, B (P1) contact at x 48..54 y 31..37, WL poly leaves at the right edge
#   (Magic console, in the layout folder: source rowdrv.tcl)
source common.tcl
snap lambda
newcell rowdrv

# rails and well taps
box 0 -3 149 3;      paint metal1
box 0 56 149 62;     paint metal1
box 70 -3 76 3;      paint psubstratepcontact
box 70 56 76 62;     paint nsubstratencontact
box 8 30 149 65;     paint nwell

# NAND2: NMOS in series (VSS - A - B - out), PMOS in parallel
box 14 6 44 21;      paint ndiffusion
box 14 36 44 53;     paint pdiffusion
box 22 4 24 55;      paint polysilicon
box 34 4 36 55;      paint polysilicon
box 14 6 20 21;      paint ndcontact
box 38 6 44 21;      paint ndcontact
box 14 36 20 53;     paint pdcontact
box 26 36 32 53;     paint pdcontact
box 38 36 44 53;     paint pdcontact
box 14 -3 20 6;      paint metal1
box 14 53 20 56;     paint metal1
box 38 53 44 56;     paint metal1
# input A: poly branch to the left, input B: poly branch to the right
box 8 26 22 28;      paint polysilicon
box 2 24 8 30;       paint polycontact
box 36 32 48 34;     paint polysilicon
box 48 31 54 37;     paint polycontact
# NAND output: PMOS drain + NMOS drain -> metal1 to the inverter input
box 26 28 32 36;     paint metal1
box 26 25 106 28;    paint metal1
box 38 21 44 25;     paint metal1

# inverter, 2 fingers: S - g1 - WL - g2 - S
box 104 6 134 21;    paint ndiffusion
box 104 36 134 53;   paint pdiffusion
box 112 4 114 55;    paint polysilicon
box 124 4 126 55;    paint polysilicon
box 112 27 126 29;   paint polysilicon
box 106 25 112 31;   paint polycontact
box 104 6 110 21;    paint ndcontact
box 116 6 122 21;    paint ndcontact
box 128 6 134 21;    paint ndcontact
box 104 36 110 53;   paint pdcontact
box 116 36 122 53;   paint pdcontact
box 128 36 134 53;   paint pdcontact
box 104 -3 110 6;    paint metal1
box 128 -3 134 6;    paint metal1
box 104 53 110 56;   paint metal1
box 128 53 134 56;   paint metal1
# WL: drain strip -> poly contact -> poly at the array's word-line height (y 5..7)
box 116 21 122 36;   paint metal1
box 122 27 143 33;   paint metal1
box 137 27 143 33;   paint polycontact
box 139 5 141 27;    paint polysilicon
box 139 5 149 7;     paint polysilicon

box 0 0 149 59
save rowdrv
