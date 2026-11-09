v {xschem version=3.4.8RC file_version=1.3}
G {}
K {type=subcircuit
format="@name @pinlist @symname"
template="name=x1"
}
V {}
S {}
E {}
N -100 -360 -100 -90 {lab=BL}
N 100 -360 100 100 {lab=BLB}
C {iopin.sym} -100 -360 3 0 {name=p1 lab=BL}
C {iopin.sym} 100 -360 3 0 {name=p2 lab=BLB}
C {pmos4.sym} -160 -280 0 0 {name=MPC1 model=pfet w=3.6u l=0.6u m=1}
C {pmos4.sym} 160 -280 0 1 {name=MPC2 model=pfet w=3.6u l=0.6u m=1}
N -140 -250 -100 -250 {lab=BL}
N 140 -250 100 -250 {lab=BLB}
N -140 -310 -140 -340 {lab=VDD}
N -140 -280 -120 -280 {lab=VDD}
N -120 -280 -120 -340 {lab=VDD}
N -120 -340 -140 -340 {lab=VDD}
N -140 -340 -200 -340 {lab=VDD}
C {lab_pin.sym} -200 -340 0 0 {name=l1 lab=VDD}
N -180 -280 -220 -280 {lab=PRE_N}
N 140 -310 140 -340 {lab=VDD}
N 140 -280 120 -280 {lab=VDD}
N 120 -280 120 -340 {lab=VDD}
N 120 -340 140 -340 {lab=VDD}
N 140 -340 200 -340 {lab=VDD}
C {lab_pin.sym} 200 -340 0 1 {name=l2 lab=VDD}
N 180 -280 220 -280 {lab=PRE_N}
C {ipin.sym} -220 -280 0 0 {name=p3 lab=PRE_N}
C {lab_pin.sym} 220 -280 0 1 {name=l3 lab=PRE_N}
C {pmos4.sym} 0 -200 1 0 {name=MPEQ model=pfet w=1.8u l=0.6u m=1}
N -30 -180 -100 -180 {lab=BL}
N 30 -180 100 -180 {lab=BLB}
N 0 -220 0 -250 {lab=PRE_N}
N 0 -250 40 -250 {lab=PRE_N}
C {lab_pin.sym} 40 -250 0 1 {name=l4 lab=PRE_N}
N 0 -180 0 -150 {lab=VDD}
N 0 -150 40 -150 {lab=VDD}
C {lab_pin.sym} 40 -150 0 1 {name=l5 lab=VDD}
C {nmos4.sym} -160 -60 0 0 {name=MNW1 model=nfet w=3.6u l=0.6u m=1}
C {nmos4.sym} 160 -60 0 1 {name=MNW2 model=nfet w=3.6u l=0.6u m=1}
N -140 -90 -100 -90 {lab=BL}
N 140 -90 100 -90 {lab=BLB}
N -140 -30 -140 0 {lab=D}
N -140 0 -180 0 {lab=D}
C {lab_pin.sym} -180 0 0 0 {name=l6 lab=D}
N 140 -30 140 0 {lab=DB}
N 140 0 180 0 {lab=DB}
C {lab_pin.sym} 180 0 0 1 {name=l7 lab=DB}
N -180 -60 -220 -60 {lab=WE}
C {ipin.sym} -220 -60 0 0 {name=p4 lab=WE}
N 180 -60 220 -60 {lab=WE}
C {lab_pin.sym} 220 -60 0 1 {name=l8 lab=WE}
N -140 -60 -120 -60 {lab=VSS}
C {lab_pin.sym} -120 -60 0 1 {name=l9 lab=VSS}
N 140 -60 120 -60 {lab=VSS}
C {lab_pin.sym} 120 -60 0 0 {name=l10 lab=VSS}
C {inv.sym} -330 130 0 0 {name=xdrv1}
C {inv.sym} -200 130 0 0 {name=xdrv2}
C {inv.sym} 200 130 0 0 {name=xsense}
C {ipin.sym} -400 130 0 0 {name=p5 lab=DIN}
N -400 130 -370 130 {lab=DIN}
N -290 130 -240 130 {lab=DB}
N -265 130 -265 160 {lab=DB}
C {lab_pin.sym} -265 160 1 0 {name=l11 lab=DB}
N -160 130 -120 130 {lab=D}
C {lab_pin.sym} -120 130 0 1 {name=l12 lab=D}
N 100 100 100 130 {lab=BLB}
N 100 130 160 130 {lab=BLB}
N 240 130 300 130 {lab=DOUT}
C {opin.sym} 300 130 0 0 {name=p6 lab=DOUT}
N -330 90 -330 70 {lab=VDD}
N -330 70 -300 70 {lab=VDD}
C {lab_pin.sym} -300 70 0 1 {name=l13 lab=VDD}
N -330 170 -330 190 {lab=VSS}
N -330 190 -300 190 {lab=VSS}
C {lab_pin.sym} -300 190 0 1 {name=l14 lab=VSS}
N -200 90 -200 70 {lab=VDD}
N -200 70 -170 70 {lab=VDD}
C {lab_pin.sym} -170 70 0 1 {name=l15 lab=VDD}
N -200 170 -200 190 {lab=VSS}
N -200 190 -170 190 {lab=VSS}
C {lab_pin.sym} -170 190 0 1 {name=l16 lab=VSS}
N 200 90 200 70 {lab=VDD}
N 200 70 230 70 {lab=VDD}
C {lab_pin.sym} 230 70 0 1 {name=l17 lab=VDD}
N 200 170 200 190 {lab=VSS}
N 200 190 230 190 {lab=VSS}
C {lab_pin.sym} 230 190 0 1 {name=l18 lab=VSS}
C {iopin.sym} -400 -330 0 1 {name=p7 lab=VDD}
C {iopin.sym} -400 -300 0 1 {name=p8 lab=VSS}
T {column circuit: precharge / equalize (PRE_N=0), write switches (WE=1), sense (DOUT = not BLB)} -400 -440 0 0 0.35 0.35 {}
T {write: BL = D = DIN, BLB = DB = not DIN} -400 230 0 0 0.3 0.3 {}
