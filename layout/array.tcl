# 4 x 4 array of the 6T cell (needs sram6t.mag in this folder)
#   sram6t_x2  : two rows, the upper one flipped so that both share the VDD rail
#   sram6t_4x4 : 4 columns x 2 blocks of sram6t_x2 (pitch 60 x 118 lambda)
#   sram_array : the array + word-line pins (left), VDD/VSS buses (right), bit-line pins (bottom)
# all three steps at once (Magic console, in the layout folder): source array.tcl
foreach f {array_1_rows array_2_4x4 array_3_edges} {
  source $f.tcl
}
