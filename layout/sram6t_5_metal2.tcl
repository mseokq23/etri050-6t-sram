# 6T cell step 5: bit lines on metal2
# (Magic console, in the layout folder: source sram6t_5_metal2.tcl)
snap lambda
load sram6t

box -1 18 8 28;   paint metal1
box 0 20 7 27;    paint m2contact
box 1 -3 5 62;    paint metal2
box 46 18 55 28;  paint metal1
box 47 20 54 27;  paint m2contact
box 49 -3 53 62;  paint metal2

save sram6t
