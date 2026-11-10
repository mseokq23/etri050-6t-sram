# 16 x 16 array: the part 1 cell and blocks (part 1 scripts, cells saved in this folder),
# then 4 x 4 copies of the part 1 4x4 block (pitch 240 x 236 lambda)
#   (Magic console, in the layout folder: source array16.tcl)
source common.tcl
# start the part 1 cells empty, so running this again does not stack copies on the old ones
foreach c {sram6t_4x4 sram6t_x2 sram6t} { newcell $c }
foreach f {sram6t_1_nmos sram6t_2_pmos sram6t_3_poly sram6t_4_metal1 sram6t_5_metal2 sram6t_6_ports array_1_rows array_2_4x4} {
  source ../../layout/$f.tcl
}
snap lambda
newcell sram16x16
for {set c 0} {$c < 4} {incr c} {
  for {set r 0} {$r < 4} {incr r} {
    getcell sram6t_4x4 child 0 0 parent [expr {240*$c}] [expr {236*$r}]
  }
}
save sram16x16
