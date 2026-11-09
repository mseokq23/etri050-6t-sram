# 4x4 array step 1: two rows sharing the VDD rail
# (Magic console, in the layout folder: source array_1_rows.tcl)
snap lambda
load sram6t_x2
getcell sram6t child 0 0 parent 0 0
getcell sram6t v child 0 0 parent 0 118
save sram6t_x2
