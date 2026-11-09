# 6T cell step 3: gate poly and the cross-couple poly contacts
# (Magic console, in the layout folder: source sram6t_3_poly.tcl)
snap lambda
load sram6t

box 20 10 22 54;  paint polysilicon
box 32 10 34 54;  paint polysilicon
box 21 27 27 33;  paint polycontact
box 27 37 33 43;  paint polycontact

save sram6t
