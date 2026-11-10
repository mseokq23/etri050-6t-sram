# sram64x4 macro: blocks + routes between them + power lines
#   array (0,0) | row decoder (-149,0) | column periphery (0,-3) | sense amps / write drivers (0,-134)
#   control block (-206,-990): pins on its top edge line up with the routes below, bottom edge = macro pins
#   power: VSS / VDD metal2 lines left (x -251..-238 / -234..-221) and right (x 975..988 / 992..1005),
#          joined by metal1 lines above (y 955..968 / 972..985) and below (y -1007..-994 / -1024..-1011)
#   every via sits at least 3 lambda inside the metal around it (the ETRI GDS style trims free via edges by 0.05 um)
#   (Magic console, in the layout folder, after the block scripts: source macro.tcl)
source common.tcl
snap lambda
newcell sram64x4

getcell sram16x16 child 0 0 parent 0 0
getcell rowdec child 0 0 parent -149 0
getcell colperi child 0 0 parent 0 -3
getcell sabank child 0 0 parent 0 -134
getcell sram64x4_ctrl child 0 0 parent -206 -990

# ---- row predecode lines down to the control block (P1 jogs 4 lambda left, one line at a time) ----
for {set i 0} {$i < 4} {incr i} {
  set x [expr {-193 + 10*$i}]
  box $x -298 [expr {$x + 4}] -3;  paint metal2
}
for {set j 0} {$j < 4} {incr j} {
  set x [expr {-89 + 10*$j}]
  set y [expr {-160 - 8*$j}]
  box $x [expr {$y - 4}] [expr {$x + 4}] -3;           paint metal2
  box [expr {$x - 4}] [expr {$y - 4}] [expr {$x + 4}] $y;  paint metal2
  box [expr {$x - 4}] -298 $x $y;                      paint metal2
}

# ---- column mux lines: metal1 continued left, metal2 down to the control block ----
for {set k 0} {$k < 4} {incr k} {
  set x [expr {-153 + 10*$k}]
  set y [expr {-71 - 10*$k}]
  box -158 $y -40 [expr {$y + 4}];                         paint metal1
  box [expr {$x - 2}] [expr {$y - 2}] [expr {$x + 5}] [expr {$y + 5}];  paint m2contact
  box $x -298 [expr {$x + 4}] [expr {$y + 4}];             paint metal2
}

# ---- SAE, WDEN (sense-amp lines continued left), PRE_N (both poly contacts) ----
box -118 -235 -40 -229;  paint metal1
box -115 -236 -108 -229; paint m2contact
box -113 -298 -109 -229; paint metal2
box -105 -247 -40 -241;  paint metal1
box -105 -248 -98 -241;  paint m2contact
box -103 -298 -99 -241;  paint metal2
box -48 -24 -8 -18;      paint metal1
box -45 -25 -38 -18;     paint m2contact
box -48 -147 -8 -141;    paint metal1
box -45 -148 -38 -141;   paint m2contact
box -43 -298 -39 -18;    paint metal2

# ---- per bit: SAO straight down, DQB / DQ with a 1 lambda jog onto the control block tracks ----
for {set b 0} {$b < 4} {incr b} {
  set x [expr {240*$b}]
  box [expr {$x + 107}] -298 [expr {$x + 111}] -274;  paint metal2
  box [expr {$x + 146}] -286 [expr {$x + 150}] -274;  paint metal2
  box [expr {$x + 146}] -286 [expr {$x + 151}] -282;  paint metal2
  box [expr {$x + 147}] -298 [expr {$x + 151}] -282;  paint metal2
  box [expr {$x + 158}] -286 [expr {$x + 162}] -274;  paint metal2
  box [expr {$x + 157}] -286 [expr {$x + 162}] -282;  paint metal2
  box [expr {$x + 157}] -298 [expr {$x + 161}] -282;  paint metal2
}

# ---- power lines ----
box -251 -1007 -238 968;   paint metal2
box -234 -1024 -221 985;   paint metal2
box 975 -1007 988 968;     paint metal2
box 992 -1024 1005 985;    paint metal2
box -251 955 988 968;      paint metal1
box -234 972 1005 985;     paint metal1
box -251 -1007 988 -994;   paint metal1
box -234 -1024 1005 -1011; paint metal1
foreach {x y} {-248 958  978 958  -248 -1004  978 -1004  -231 975  995 975  -231 -1021  995 -1021} {
  box $x $y [expr {$x + 7}] [expr {$y + 7}];  paint m2contact
}
# rails of the array and the decoder: VSS at y 118p (p = 0..8), VDD at y 118p + 59 (p = 0..7)
for {set p 0} {$p <= 8} {incr p} {
  set y [expr {118*$p}]
  box -251 [expr {$y - 3}] -149 [expr {$y + 3}];  paint metal1
  box 960 [expr {$y - 3}] 988 [expr {$y + 3}];    paint metal1
  box -248 [expr {$y - 3}] -241 [expr {$y + 4}];  paint m2contact
  box 978 [expr {$y - 3}] 985 [expr {$y + 4}];    paint m2contact
}
for {set p 0} {$p < 8} {incr p} {
  set y [expr {118*$p + 59}]
  box -234 [expr {$y - 3}] -149 [expr {$y + 3}];  paint metal1
  box 960 [expr {$y - 3}] 1005 [expr {$y + 3}];   paint metal1
  box -231 [expr {$y - 3}] -224 [expr {$y + 4}];  paint m2contact
  box 995 [expr {$y - 3}] 1002 [expr {$y + 4}];   paint m2contact
}
# column periphery VDD (y -18..-12), sense-amp VDD (y -140..-134) and VSS (y -223..-217)
box 960 -18 1005 -12;      paint metal1
box 995 -18 1002 -11;      paint m2contact
box 960 -140 1005 -134;    paint metal1
box 995 -140 1002 -133;    paint m2contact
box -251 -223 -40 -217;    paint metal1
box 960 -223 988 -217;     paint metal1
box -248 -223 -241 -216;   paint m2contact
box 978 -223 985 -216;     paint m2contact
# control block rails (gnd y -870 / -630 / -390, vdd y -750 / -510) continued right
foreach {net y} {gnd -870 vdd -750 gnd -630 vdd -510 gnd -390} {
  if {$net eq "gnd"} {
    box 954 [expr {$y - 4}] 988 [expr {$y + 4}];   paint metal1
    box 978 [expr {$y - 3}] 985 [expr {$y + 4}];   paint m2contact
  } else {
    box 954 [expr {$y - 4}] 1005 [expr {$y + 4}];  paint metal1
    box 995 [expr {$y - 3}] 1002 [expr {$y + 4}];  paint m2contact
  }
}

# ---- macro pins: short metal2 below the control block's bottom pins ----
set n 0
foreach p {A[0] A[1] A[2] A[3] A[4] A[5] WE CLK DIN[0] DIN[1] DIN[2] DIN[3] DOUT[0] DOUT[1] DOUT[2] DOUT[3]} {
  set x [expr {-193 + 70*$n}]
  box $x -1030 [expr {$x + 4}] -982;  paint metal2
  box $x -1030 [expr {$x + 4}] -1026; label $p c metal2
  incr n
}
box 992 -1024 1005 -1020;  label VDD c metal2
box 975 -1007 988 -1003;   label VSS c metal2
# port makeall works on the labels inside the box
box -260 -1040 1010 990
port makeall
save sram64x4
