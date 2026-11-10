# row decoder: 16 row drivers (8 pairs, odd rows flipped like the array) + predecode lines on metal2
#   P0[0..3] (from A[1:0]) left of the drivers, P1[0..3] (from A[3:2]) between NAND and inverter
#   row r uses P0[r % 4] and P1[r / 4]: a metal1 stub + via on each of its two lines
#   (Magic console, in the layout folder, after rowdrv.tcl: source rowdec.tcl)
source common.tcl
snap lambda
newcell rowdrv_x2
getcell rowdrv child 0 0 parent 0 0
getcell rowdrv v child 0 0 parent 0 118
save rowdrv_x2

newcell rowdec
for {set p 0} {$p < 8} {incr p} {
  getcell rowdrv_x2 child 0 0 parent 0 [expr {$p * 118}]
}
# predecode lines: P0[i] at x -44+10i, P1[j] at x 60+10j (4 wide, pitch 10)
for {set k 0} {$k < 4} {incr k} {
  box [expr {-44 + 10*$k}] -3 [expr {-40 + 10*$k}] 947;  paint metal2
  box [expr {60 + 10*$k}] -3 [expr {64 + 10*$k}] 947;    paint metal2
}
# taps: input A contact at y 24..30, input B contact at y 31..37 (odd rows: 88..94 and 81..87)
for {set r 0} {$r < 16} {incr r} {
  set i [expr {$r % 4}]
  set j [expr {$r / 4}]
  set y0 [expr {($r / 2) * 118}]
  if {$r % 2 == 0} {
    set ya [expr {$y0 + 24}];  set yb [expr {$y0 + 31}];  set dv 0
  } else {
    set ya [expr {$y0 + 88}];  set yb [expr {$y0 + 81}];  set dv -1
  }
  # A: via on P0[i], metal1 to the contact at x 2..8
  box [expr {-46 + 10*$i}] [expr {$ya + $dv}] [expr {-39 + 10*$i}] [expr {$ya + $dv + 7}];  paint m2contact
  box [expr {-39 + 10*$i}] $ya 8 [expr {$ya + 6}];                                         paint metal1
  # B: metal1 from the contact at x 48..54 to a via on P1[j]
  box 54 $yb [expr {59 + 10*$j}] [expr {$yb + 6}];                                         paint metal1
  box [expr {58 + 10*$j}] [expr {$yb + $dv}] [expr {65 + 10*$j}] [expr {$yb + $dv + 7}];  paint m2contact
}
save rowdec
