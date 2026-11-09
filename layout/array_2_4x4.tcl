# 4x4 array step 2: 4 columns x 2 blocks = 4 x 4 cells
# (Magic console, in the layout folder: source array_2_4x4.tcl)
snap lambda
load sram6t_4x4
for {set c 0} {$c < 4} {incr c} {
  for {set r 0} {$r < 2} {incr r} {
    getcell sram6t_x2 child 0 0 parent [expr {$c * 60}] [expr {$r * 118}]
  }
}
save sram6t_4x4
