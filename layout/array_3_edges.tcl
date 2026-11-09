# 4x4 array step 3: edges and pins
# (Magic console, in the layout folder: source array_3_edges.tcl)
snap lambda
load sram_array
getcell sram6t_4x4 child 0 0 parent 0 0

# word lines: poly -> poly contact -> metal1 pin, left of the array
foreach {wl y} {WL0 6 WL1 112 WL2 124 WL3 230} {
  box -12 [expr {$y - 1}] 0 [expr {$y + 1}];  paint polysilicon
  box -12 [expr {$y - 3}] -6 [expr {$y + 3}]; paint polycontact
  label $wl c metal1
}

# VSS bus (x 245-256) and VDD bus (x 261-272) on metal2, right of the array
# (each via sits inside its bus so no thin metal2 piece sticks out of it; the kit KLayout deck flags those)
box 245 -10 256 243;  paint metal2
box 261 -10 272 243;  paint metal2
foreach y {0 118 236} {
  box 240 [expr {$y - 4}] 258 [expr {$y + 5}]; paint metal1
  box 247 [expr {$y - 3}] 254 [expr {$y + 4}]; paint m2contact
}
foreach y {59 177} {
  box 240 [expr {$y - 4}] 274 [expr {$y + 5}]; paint metal1
  box 263 [expr {$y - 3}] 270 [expr {$y + 4}]; paint m2contact
}
box 245 -10 256 -6;  label VSS c metal2
box 261 -10 272 -6;  label VDD c metal2

# bit-line pins: the metal2 bit lines continue 7 lambda below the array
for {set c 0} {$c < 4} {incr c} {
  set x [expr {$c * 60}]
  box [expr {$x + 1}] -10 [expr {$x + 5}] -3;   paint metal2; label BL$c c metal2
  box [expr {$x + 49}] -10 [expr {$x + 53}] -3; paint metal2; label BLB$c c metal2
}

box -14 -11 276 244
port makeall
select clear
save sram_array
