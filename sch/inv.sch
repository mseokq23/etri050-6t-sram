v {xschem version=3.4.8RC file_version=1.3}
G {}
K {type=subcircuit
format="@name @pinlist @symname"
template="name=x1"
}
V {}
S {}
E {}
C {pmos4.sym} 0 -80 0 0 {name=M1 model=pfet w=3.6u l=0.6u m=1}
C {nmos4.sym} 0 80 0 0 {name=M2 model=nfet w=1.8u l=0.6u m=1}
N 20 -50 20 50 {lab=Y}
N 20 0 100 0 {lab=Y}
N -20 -80 -60 -80 {lab=A}
N -60 -80 -60 80 {lab=A}
N -60 80 -20 80 {lab=A}
N -100 0 -60 0 {lab=A}
N 20 -110 20 -150 {lab=VDD}
N 20 -80 60 -80 {lab=VDD}
N 60 -80 60 -150 {lab=VDD}
N 20 -150 60 -150 {lab=VDD}
N 20 110 20 150 {lab=VSS}
N 20 80 60 80 {lab=VSS}
N 60 80 60 150 {lab=VSS}
N 20 150 60 150 {lab=VSS}
C {ipin.sym} -100 0 0 0 {name=p1 lab=A}
C {opin.sym} 100 0 0 0 {name=p2 lab=Y}
C {iopin.sym} 20 -150 3 0 {name=p3 lab=VDD}
C {iopin.sym} 20 150 1 0 {name=p4 lab=VSS}
T {CMOS inverter} -100 -230 0 0 0.4 0.4 {}
