# read / write circuits for the 4 bits (4 x sabit) + the lines they share
#   VDD metal1 y -6..0, PRE_N poly y -11..-9 (contact at the left end), VSS metal1 y -89..-83,
#   SAE metal1 y -101..-95, WDEN metal1 y -113..-107
#   per bit (x = 240b): SAO metal2 x 107..111, DQB x 146..150, DQ x 158..162 leave at the bottom (y -140)
#   (Magic console, in the layout folder, after sabit.tcl: source sabank.tcl)
source common.tcl
snap lambda
newcell sabank

for {set b 0} {$b < 4} {incr b} {
  getcell sabit child 0 0 parent [expr {240*$b}] 0
}
box 0 -6 960 0;        paint metal1
box -14 -11 960 -9;    paint polysilicon
box -14 -13 -8 -7;     paint polycontact
box -40 -89 960 -83;   paint metal1
box -40 -101 960 -95;  paint metal1
box -40 -113 960 -107; paint metal1
for {set b 0} {$b < 4} {incr b} {
  foreach x {10 110 200} {
    box [expr {240*$b + $x}] -89 [expr {240*$b + $x + 6}] -83;  paint psubstratepcontact
  }
}
save sabank
