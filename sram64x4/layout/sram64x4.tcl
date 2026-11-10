# whole macro in one go (Magic console, in this folder: source sram64x4.tcl)
#   ../pnr/run_pnr.sh must have run first (control block DEF)
foreach f {array16 rowdrv rowdec colmux colperi sabit sabank ctrl macro} {
  source $f.tcl
}
