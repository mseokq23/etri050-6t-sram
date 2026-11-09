v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
C {inv.sym} 300 -200 0 0 {name=x1}
C {vsource.sym} 60 -180 0 0 {name=V1 value=5 savecurrent=false}
C {vsource.sym} 160 -150 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 60 -150 0 0 {name=l1 lab=0}
C {gnd.sym} 160 -120 0 0 {name=l2 lab=0}
C {gnd.sym} 300 -140 0 0 {name=l3 lab=0}
N 60 -210 60 -260 {lab=vdd}
N 60 -260 300 -260 {lab=vdd}
N 300 -260 300 -240 {lab=vdd}
N 300 -160 300 -140 {lab=0}
N 160 -180 160 -200 {lab=in}
N 160 -200 260 -200 {lab=in}
N 340 -200 420 -200 {lab=out}
C {lab_pin.sym} 420 -200 0 1 {name=l4 lab=out}
C {lab_pin.sym} 200 -200 0 0 {name=l5 lab=in}
C {lab_pin.sym} 120 -260 0 0 {name=l6 lab=vdd}
C {code_shown.sym} 40 -70 0 0 {name=MODELS only_toplevel=false
value="tcleval(.include $::ETRI050_MODEL)"}
C {code_shown.sym} 40 0 0 0 {name=SIM only_toplevel=false
value="
.control
dc V2 0 5 0.01
let d = v(out) - v(in)
meas dc vm find v(in) when d=0
plot v(in) v(out)
.endc
"}
T {inverter VTC testbench} 40 -340 0 0 0.5 0.5 {}
