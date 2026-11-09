# CMOS inverter: PMOS 3.6/0.6, NMOS 1.8/0.6 (um), rails VSS (y=0) / VDD (y=49)
snap lambda
load inv
# rails and taps
box 0 -3 30 3;    paint metal1
box 0 46 30 52;   paint metal1
box 0 24 30 55;   paint nwell
box 12 -3 18 3;   paint psubstratepcontact
box 14 46 20 52;  paint nsubstratencontact
# NMOS
box 6 9 24 15;    paint ndiffusion
box 6 9 12 15;    paint ndcontact
box 18 9 24 15;   paint ndcontact
# PMOS
box 6 30 24 42;   paint pdiffusion
box 6 30 12 42;   paint pdcontact
box 18 30 24 42;  paint pdcontact
# gate and input contact
box 14 7 16 44;   paint polysilicon
box 8 19 14 25;   paint polycontact
# metal1: output, sources to rails
box 18 15 24 30;  paint metal1
box 6 3 12 9;     paint metal1
box 6 42 12 46;   paint metal1
# pins
box 9 20 13 24;   label A c metal1
box 19 20 23 24;  label Y c metal1
box 24 47 28 51;  label VDD c metal1
box 24 -2 28 2;   label VSS c metal1
box -1 -4 31 56
port makeall
select clear
save inv
