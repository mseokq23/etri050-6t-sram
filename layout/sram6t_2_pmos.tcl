# 6T cell step 2: PMOS (pull-ups) in the N-well
# (Magic console, in the layout folder: source sram6t_2_pmos.tcl)
snap lambda
load sram6t

box 0 40 60 65;   paint nwell
box 12 46 42 52;  paint pdiffusion
box 12 46 18 52;  paint pdcontact
box 24 46 30 52;  paint pdcontact
box 36 46 42 52;  paint pdcontact

save sram6t
