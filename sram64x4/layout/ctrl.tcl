# control block: DEF from OpenROAD (../pnr/run_pnr.sh) -> Magic layout
#   x 0 / y 0 = die origin = macro (-206, -990) lambda
#   the standard cells are the kit's own layouts (digital_ETRI is on Magic's search path),
#   the LEF is read only for the via definitions (-annotate: the real cell layouts are kept)
#   (Magic console, in the layout folder: source ctrl.tcl)
source common.tcl
snap lambda
foreach c {AND2X2 BUFX2 BUFX4 CLKBUF1 DFFNEGX1 DFFPOSX1 FILL INVX1 INVX2 INVX4 INVX8 NAND2X1 NAND3X1 NOR2X1} {
  load $c
}
lef read ../pnr/work/etri050_stdcells.lef -annotate
newcell sram64x4_ctrl
def read ../pnr/work/sram64x4_ctrl.def
# cell rails of the 4 rows: gnd at y 36 / 108 / 180 um, vdd at 72 / 144 um (y 120..600 lambda),
# joined on the left by two metal2 straps (gnd x -45..-32, vdd x -28..-15) that the macro's power lines reuse
foreach {net y} {gnd 120 vdd 240 gnd 360 vdd 480 gnd 600} {
  if {$net eq "gnd"} { set xs -45 } else { set xs -28 }
  box $xs [expr {$y - 4}] 10 [expr {$y + 4}];                                    paint metal1
  box [expr {$xs + 3}] [expr {$y - 3}] [expr {$xs + 10}] [expr {$y + 4}];  paint m2contact
}
box -45 116 -32 604;  paint metal2
box -28 236 -15 484;  paint metal2
box -45 400 -32 404;  label gnd c metal2
box -28 400 -15 404;  label vdd c metal2
# port makeall works on the labels inside the box
box -50 -10 1180 710
port makeall
save sram64x4_ctrl
