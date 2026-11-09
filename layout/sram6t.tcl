# 6T SRAM cell for the ETRI 0.5 um kit (Magic, lambda = 0.3 um)
#   cell 60 x 59 lambda (18.0 x 17.7 um), VSS rail centre y = 0, VDD rail centre y = 59
#   PU 1.8/0.6 um, PD 3.6/0.6 um, PG 1.8/0.6 um
# all six steps at once (Magic console, in the layout folder): source sram6t.tcl
foreach f {sram6t_1_nmos sram6t_2_pmos sram6t_3_poly sram6t_4_metal1 sram6t_5_metal2 sram6t_6_ports} {
  source $f.tcl
}
