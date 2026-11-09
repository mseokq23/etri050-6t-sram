# PMOS W/L = 3.6/0.6 um in an N-well, with a well tap
snap lambda
load pmos
box -6 -6 24 21;  paint nwell
box 0 0 18 12;    paint pdiffusion
box 8 -2 10 14;   paint polysilicon
box 0 0 6 12;     paint pdcontact
box 12 0 18 12;   paint pdcontact
box 6 16 12 22;   paint nsubstratencontact
save pmos
