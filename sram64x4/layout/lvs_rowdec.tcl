# LVS wrapper of the row decoder: rowdec_lvs = rowdec + a label on each pin
#   (the blocks have no labels of their own; the VDD rails of the rows, which only the macro's VDD line
#    joins, are joined here by a metal2 line on the right)
#   (Magic console, in the layout folder, after rowdec.tcl: source lvs_rowdec.tcl)
source common.tcl
snap lambda

newcell rowdec_lvs
getcell rowdec child 0 0 parent 0 0
for {set k 0} {$k < 4} {incr k} {
  pinlabel P0\[$k\] metal2 [expr {-44 + 10*$k}] 940 [expr {-40 + 10*$k}] 944
  pinlabel P1\[$k\] metal2 [expr {60 + 10*$k}] 940 [expr {64 + 10*$k}] 944
}
for {set r 0} {$r < 16} {incr r} {
  set y0 [expr {($r / 2) * 118}]
  set y [expr {$r % 2 == 0 ? $y0 + 5 : $y0 + 111}]
  pinlabel WL\[$r\] polysilicon 147 $y 149 [expr {$y + 2}]
}
for {set p 0} {$p < 8} {incr p} {
  box 149 [expr {118*$p + 56}] 159 [expr {118*$p + 62}];  paint metal1
  box 152 [expr {118*$p + 56}] 158 [expr {118*$p + 62}];  paint m2contact
}
box 152 56 158 888;  paint metal2
pinlabel VSS metal1 0 -3 4 3
pinlabel VDD metal1 0 56 4 62
box -60 -10 160 960
port makeall
save rowdec_lvs
