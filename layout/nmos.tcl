# NMOS W/L = 1.8/0.6 um (6 x 2 lambda) - first Magic exercise
snap lambda
load nmos
box 0 0 18 6;     paint ndiffusion
box 8 -2 10 8;    paint polysilicon
box 0 0 6 6;      paint ndcontact
box 12 0 18 6;    paint ndcontact
save nmos
