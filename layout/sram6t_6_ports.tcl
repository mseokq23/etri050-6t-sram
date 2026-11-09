# 6T cell step 6: labels -> ports
# (Magic console, in the layout folder: source sram6t_6_ports.tcl)
snap lambda
load sram6t

box 1 40 5 44;    label BL c metal2
box 49 40 53 44;  label BLB c metal2
box 56 5 58 7;    label WL c polysilicon
box 54 57 58 61;  label VDD c metal1
box 54 -2 58 2;   label VSS c metal1
box -1 -3 60 65
port makeall
# internal nodes: plain labels (net names for simulation, not ports)
box 14 30 16 32;  label Q c metal1
box 38 36 40 38;  label QB c metal1
select clear
box 0 0 60 59

save sram6t
