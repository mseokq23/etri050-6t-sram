# one bit of the read / write circuit, 240 lambda wide (= 4 columns), y = 0 at the top going down
#   latch sense amp (cross-coupled pair + 2-finger tail on SAE + DL / DLB precharge on PRE_N)
#   output inverter DLB -> SAO (right), matching dummy inverter on DL (left), write driver (NMOS stacks)
#   global lines drawn by sabank.tcl: VDD (y -6..0), PRE_N poly (y -11..-9), VSS (-89..-83), SAE (-101..-95), WDEN (-113..-107)
#   (Magic console, in the layout folder: source sabit.tcl)
source common.tcl
snap lambda
newcell sabit

box 4 -33 118 3;     paint nwell
box 58 -6 64 0;      paint nsubstratencontact

# PMOS row: dummy inverter | precharge + latch | output inverter
box 10 -27 28 -15;   paint pdiffusion
box 34 -23 88 -15;   paint pdiffusion
box 94 -27 112 -15;  paint pdiffusion
foreach x {10 22 94 106} { box $x -27 [expr {$x + 6}] -15; paint pdcontact }
foreach x {34 46 58 70 82} { box $x -23 [expr {$x + 6}] -15; paint pdcontact }
foreach x {22 34 58 82 94} { box $x -15 [expr {$x + 6}] -6; paint metal1 }
box 42 -25 44 -9;    paint polysilicon
box 78 -25 80 -9;    paint polysilicon

# NMOS row: dummy inverter | latch pair | output inverter | write driver
box 10 -51 28 -45;   paint ndiffusion
box 46 -57 76 -45;   paint ndiffusion
box 94 -51 112 -45;  paint ndiffusion
box 130 -61 178 -45; paint ndiffusion
foreach x {10 22 94 106} { box $x -51 [expr {$x + 6}] -45; paint ndcontact }
foreach x {46 58 70} { box $x -57 [expr {$x + 6}] -45; paint ndcontact }
foreach x {130 151 172} { box $x -61 [expr {$x + 6}] -45; paint ndcontact }

# gates: dummy, latch (gDLB, gDL), output, write driver (WDEN, DQB, DQ, WDEN)
box 18 -53 20 -13;   paint polysilicon
box 54 -59 56 -13;   paint polysilicon
box 66 -59 68 -13;   paint polysilicon
box 102 -53 104 -13; paint polysilicon
box 138 -110 140 -43; paint polysilicon
box 147 -122 149 -43; paint polysilicon
box 159 -122 161 -43; paint polysilicon
box 168 -110 170 -43; paint polysilicon

# node strips: SAX, DL, DLB, SAO (PMOS drain to NMOS drain)
box 10 -45 16 -27;   paint metal1
box 46 -45 52 -23;   paint metal1
box 70 -45 76 -23;   paint metal1
box 106 -45 112 -27; paint metal1

# cross-coupling and inverter inputs
box 55 -32 61 -26;   paint polycontact
box 55 -32 76 -26;   paint metal1
box 61 -42 67 -36;   paint polycontact
box 19 -42 25 -36;   paint polycontact
box 19 -42 67 -36;   paint metal1
box 97 -42 103 -36;  paint polycontact
box 76 -42 103 -36;  paint metal1

# tail: 2 fingers on SAE, sources to VSS, drain to the latch
box 46 -80 76 -68;   paint ndiffusion
foreach x {46 58 70} { box $x -80 [expr {$x + 6}] -68; paint ndcontact }
box 54 -82 56 -66;   paint polysilicon
box 66 -82 68 -66;   paint polysilicon
box 54 -84 68 -82;   paint polysilicon
box 60 -97 62 -84;   paint polysilicon
box 58 -101 64 -95;  paint polycontact
box 58 -68 64 -57;   paint metal1

# VSS straps down to the VSS line
foreach x {22 94} { box $x -83 [expr {$x + 6}] -51; paint metal1 }
foreach x {46 70} { box $x -83 [expr {$x + 6}] -80; paint metal1 }
box 151 -83 157 -61; paint metal1

# write driver gate contacts: WDEN on the WDEN line, DQB / DQ -> vias -> metal2 down
box 136 -113 142 -107; paint polycontact
box 166 -113 172 -107; paint polycontact
box 145 -125 151 -119; paint polycontact
box 157 -125 163 -119; paint polycontact
box 145 -127 151 -125; paint metal1
box 157 -127 163 -125; paint metal1
box 145 -134 152 -127; paint m2contact
box 157 -134 164 -127; paint m2contact
box 146 -140 150 -127; paint metal2
box 158 -140 162 -127; paint metal2

# SAO -> via -> metal2 down
box 106 -60 112 -51; paint metal1
box 106 -60 113 -53; paint m2contact
box 107 -140 111 -53; paint metal2

# DL / DLB up to the data lines of the column periphery (DL line y 18..25, DLB line y 6..13 here)
#   (the write driver's DLB lands on the column periphery's own DLB via at x 167..174)
box 28 -42 35 -35;   paint m2contact
box 29 -42 33 25;    paint metal2
box 28 18 35 25;     paint m2contact
box 84 -42 91 -35;   paint m2contact
box 85 -42 89 13;    paint metal2
box 84 6 91 13;      paint m2contact
box 130 -45 137 -35; paint metal1
box 130 -42 137 -35; paint m2contact
box 132 -42 136 25;  paint metal2
box 131 18 138 25;   paint m2contact
box 171 -45 178 -35; paint metal1
box 171 -42 178 -35; paint m2contact
box 173 -42 177 0;   paint metal2
box 167 0 177 6;     paint metal2
box 167 6 174 13;    paint m2contact

box 0 -140 240 0
save sabit
