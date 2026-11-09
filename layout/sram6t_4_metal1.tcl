# 6T cell step 4: metal1 (Q, QB, rails) and the substrate / well taps
# (Magic console, in the layout folder: source sram6t_4_metal1.tcl)
snap lambda
load sram6t

box 12 24 18 46;  paint metal1
box 36 24 42 46;  paint metal1
box 21 27 42 33;  paint metal1
box 12 37 33 43;  paint metal1
box 0 -3 60 3;    paint metal1
box 24 3 30 12;   paint metal1
box 0 56 60 62;   paint metal1
box 24 52 30 56;  paint metal1
box 24 -3 30 3;   paint psubstratepcontact
box 24 56 30 62;  paint nsubstratencontact

save sram6t
