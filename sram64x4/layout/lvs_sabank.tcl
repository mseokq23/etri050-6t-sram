# LVS wrapper of the sense amps + write drivers: sabank_lvs = sabank + a label on each pin
#   (the two DL / DLB pieces of a bit are joined by the column periphery's data lines in the macro:
#    the same metal1 lines are drawn here)
#   (Magic console, in the layout folder, after sabank.tcl: source lvs_sabank.tcl)
source common.tcl
snap lambda

newcell sabank_lvs
getcell sabank child 0 0 parent 0 0
pinlabel VDD metal1 0 -6 4 0
pinlabel PRE_N metal1 -14 -13 -8 -7
pinlabel VSS metal1 -40 -89 -36 -83
pinlabel SAE metal1 -40 -101 -36 -95
pinlabel WDEN metal1 -40 -113 -36 -107
for {set b 0} {$b < 4} {incr b} {
  set x [expr {240*$b}]
  pinlabel SAO\[$b\] metal2 [expr {$x + 107}] -140 [expr {$x + 111}] -136
  pinlabel DQB\[$b\] metal2 [expr {$x + 146}] -140 [expr {$x + 150}] -136
  pinlabel DQ\[$b\] metal2 [expr {$x + 158}] -140 [expr {$x + 162}] -136
  box [expr {$x + 28}] 18 [expr {$x + 138}] 25;  paint metal1
  box [expr {$x + 84}] 6 [expr {$x + 174}] 13;   paint metal1
  pinlabel DL\[$b\] metal1 [expr {$x + 60}] 18 [expr {$x + 64}] 25
  pinlabel DLB\[$b\] metal1 [expr {$x + 120}] 6 [expr {$x + 124}] 13
}
box -50 -150 970 30
port makeall
save sabank_lvs
