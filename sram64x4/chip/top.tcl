# sram64x4 chip top: the macro as the core on the pad frame, routes from chip_routes.tcl (make_top.py)
#   (run_chip.sh runs it in chip/work: magic -dnull -noconsole < ../top.tcl)
source chip_routes.tcl

# chip top for the kit's flow: pads (template) + sram64x4_Core + routes painted in the top cell
load sram64x4_Top
place_core sram64x4_Core
draw_routes
save sram64x4_Top

# route check cell: the same macro and routes without the pads, labels on the pad pins
#   (check_chip.sh extracts it and compares with chipnet_top.spice)
load sram64x4_chipnet
place_core sram64x4
draw_routes
pad_labels
box 0 0 1900um 1900um
port makeall
save sram64x4_chipnet
quit -noprompt
