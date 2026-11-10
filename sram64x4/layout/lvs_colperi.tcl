# LVS wrapper of the column periphery: colperi_lvs = colperi + a label on each pin
#   (the column mux NMOS sit on the bare substrate, which the other blocks tie to VSS in the macro:
#    a tap labelled VSS stands in for them here)
#   (Magic console, in the layout folder, after colperi.tcl: source lvs_colperi.tcl)
source common.tcl
snap lambda

newcell colperi_lvs
getcell colperi child 0 0 parent 0 0
for {set c 0} {$c < 16} {incr c} {
  set x [expr {60*$c}]
  pinlabel BL\[$c\] metal2 [expr {$x + 1}] -4 [expr {$x + 5}] 0
  pinlabel BLB\[$c\] metal2 [expr {$x + 49}] -4 [expr {$x + 53}] 0
}
for {set b 0} {$b < 4} {incr b} {
  set x [expr {240*$b}]
  pinlabel DL\[$b\] metal1 [expr {$x + 100}] -113 [expr {$x + 104}] -106
  pinlabel DLB\[$b\] metal1 [expr {$x + 150}] -125 [expr {$x + 154}] -118
}
for {set k 0} {$k < 4} {incr k} {
  pinlabel MUX\[$k\] metal1 -40 [expr {-68 - 10*$k}] -36 [expr {-64 - 10*$k}]
}
pinlabel PRE_N metal1 -14 -21 -8 -15
pinlabel VDD metal1 0 -15 4 -9
box -40 -40 -34 -34;  paint psubstratepcontact
pinlabel VSS metal1 -40 -40 -34 -34
box -50 -140 970 5
port makeall
save colperi_lvs
