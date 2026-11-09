v {xschem version=3.4.8RC file_version=1.3}
G {}
K {type=subcircuit
format="@name @pinlist @symname"
template="name=x1"
}
V {}
S {}
E {}
C {pmos4.sym} -100 -80 0 0 {name=MPUL model=pfet w=1.8u l=0.6u m=1}
C {nmos4.sym} -100 80 0 0 {name=MPDL model=nfet w=3.6u l=0.6u m=1}
C {pmos4.sym} 100 -80 0 1 {name=MPUR model=pfet w=1.8u l=0.6u m=1}
C {nmos4.sym} 100 80 0 1 {name=MPDR model=nfet w=3.6u l=0.6u m=1}
N -80 -50 -80 50 {lab=Q}
N 80 -50 80 50 {lab=QB}
N -80 -110 -80 -150 {lab=VDD}
N -80 -80 -40 -80 {lab=VDD}
N -40 -80 -40 -150 {lab=VDD}
N -80 110 -80 150 {lab=VSS}
N -80 80 -40 80 {lab=VSS}
N -40 80 -40 150 {lab=VSS}
N 80 -110 80 -150 {lab=VDD}
N 80 -80 40 -80 {lab=VDD}
N 40 -80 40 -150 {lab=VDD}
N 80 110 80 150 {lab=VSS}
N 80 80 40 80 {lab=VSS}
N 40 80 40 150 {lab=VSS}
N -80 -150 80 -150 {lab=VDD}
N -80 150 80 150 {lab=VSS}
N -120 -80 -140 -80 {lab=QB}
N -140 -80 -140 80 {lab=QB}
N -140 80 -120 80 {lab=QB}
N 120 -80 140 -80 {lab=Q}
N 140 -80 140 80 {lab=Q}
N 140 80 120 80 {lab=Q}
N -80 20 140 20 {lab=Q}
N 80 -20 -140 -20 {lab=QB}
C {nmos4.sym} -230 0 1 0 {name=MPGL model=nfet w=1.8u l=0.6u m=1}
C {nmos4.sym} 230 0 1 0 {name=MPGR model=nfet w=1.8u l=0.6u m=1}
N -200 20 -80 20 {lab=Q}
N 200 20 180 20 {lab=QB}
N 180 20 180 -20 {lab=QB}
N 180 -20 80 -20 {lab=QB}
N -260 20 -300 20 {lab=BL}
N 260 20 300 20 {lab=BLB}
N -230 -20 -230 -200 {lab=WL}
N 230 -20 230 -200 {lab=WL}
N -230 -200 230 -200 {lab=WL}
C {ipin.sym} -300 -200 0 0 {name=p3 lab=WL}
N -300 -200 -230 -200 {lab=WL}
C {lab_pin.sym} -230 70 3 0 {name=l1 lab=VSS}
N -230 20 -230 70 {lab=VSS}
C {lab_pin.sym} 230 70 3 0 {name=l2 lab=VSS}
N 230 20 230 70 {lab=VSS}
C {iopin.sym} -300 20 0 1 {name=p1 lab=BL}
C {iopin.sym} 300 20 0 0 {name=p2 lab=BLB}
C {iopin.sym} 0 -150 3 0 {name=p4 lab=VDD}
C {iopin.sym} 0 150 1 0 {name=p5 lab=VSS}
C {lab_pin.sym} -80 40 0 1 {name=l3 lab=Q}
C {lab_pin.sym} 80 50 0 0 {name=l4 lab=QB}
T {6T SRAM cell   PU 1.8/0.6   PD 3.6/0.6   PG 1.8/0.6  (um)} -300 -290 0 0 0.4 0.4 {}
