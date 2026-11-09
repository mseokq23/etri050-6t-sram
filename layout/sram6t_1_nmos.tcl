# 6T cell step 1: NMOS (pass gates + pull-downs) and the word line
# (Magic console, in the layout folder: source sram6t_1_nmos.tcl)
snap lambda
load sram6t

box 0 12 54 18;   paint ndiffusion
box 12 12 42 24;  paint ndiffusion
box 0 5 60 7;     paint polysilicon
box 8 5 10 20;    paint polysilicon
box 44 5 46 20;   paint polysilicon
box 0 12 6 18;    paint ndcontact
box 12 12 18 24;  paint ndcontact
box 24 12 30 24;  paint ndcontact
box 36 12 42 24;  paint ndcontact
box 48 12 54 18;  paint ndcontact

save sram6t
