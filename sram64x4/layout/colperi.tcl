# column periphery: 16 x colmux + MUX[0..3] lines + data lines DL[b] / DLB[b] (b = column / 4)
#   MUX[k] metal1 lines at y -68-10k .. -64-10k, column c taps MUX[c % 4]
#   DL[b] metal1 y -113..-106, DLB[b] metal1 y -125..-118 (one pair per group of 4 columns)
#   PRE_N poly contact at the left end (x -14..-8)
#   (Magic console, in the layout folder, after colmux.tcl: source colperi.tcl)
source common.tcl
snap lambda
newcell colperi

for {set c 0} {$c < 16} {incr c} {
  getcell colmux child 0 0 parent [expr {60*$c}] 0
}
# MUX lines and taps
for {set k 0} {$k < 4} {incr k} {
  box -40 [expr {-68 - 10*$k}] 960 [expr {-64 - 10*$k}];  paint metal1
}
for {set c 0} {$c < 16} {incr c} {
  set x [expr {60*$c}]
  set k [expr {$c % 4}]
  box [expr {$x + 25}] [expr {-70 - 10*$k}] [expr {$x + 29}] -60;           paint metal2
  box [expr {$x + 24}] [expr {-70 - 10*$k}] [expr {$x + 31}] [expr {-63 - 10*$k}];  paint m2contact
  # MUX[0]: the two vias are only 3 lambda apart, one metal2 piece around both
  if {$k == 0} { box [expr {$x + 23}] -71 [expr {$x + 32}] -52;  paint metal2 }
}
# data lines: drops on metal2 (x 1..5 for DL, 49..53 for DLB), lines on metal1
for {set c 0} {$c < 16} {incr c} {
  set x [expr {60*$c}]
  box [expr {$x + 1}] -113 [expr {$x + 5}] -60;    paint metal2
  box $x -113 [expr {$x + 7}] -106;                paint m2contact
  box [expr {$x + 49}] -125 [expr {$x + 53}] -60;  paint metal2
  box [expr {$x + 47}] -125 [expr {$x + 54}] -118; paint m2contact
}
for {set b 0} {$b < 4} {incr b} {
  set x [expr {240*$b}]
  box $x -113 [expr {$x + 187}] -106;              paint metal1
  box [expr {$x + 47}] -125 [expr {$x + 234}] -118; paint metal1
}
# PRE_N: poly continued to a contact at the left end
box -14 -19 0 -17;   paint polysilicon
box -14 -21 -8 -15;  paint polycontact

save colperi
