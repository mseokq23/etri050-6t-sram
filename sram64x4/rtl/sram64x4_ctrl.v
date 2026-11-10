// sram64x4 control block: input registers, decoders, timing signals
// gate-level netlist with the ETRI 0.5 um kit standard cells (digital_ETRI),
// power pins written out so the same file works for vlog2Spice (simulation, LVS) and OpenROAD
//
//   CLK rise : A, WE, DIN are captured (DFFPOSX1)
//   CLK high : WL_EN (= CLK & CLK_D1) opens the row predecoder P1 -> one WL goes high
//              read : at CLK_D3 the column mux closes, then SAE fires the sense amps
//              write: WDEN (= WL_EN & WE) turns on the write drivers
//   CLK fall : WL off, then PRE_N (= CLK | CLK_D1) starts the precharge, DOUT is captured (DFFNEGX1)
module sram64x4_ctrl (
    inout  vdd,
    inout  gnd,
    input  CLK,
    input  WE,
    input  [5:0] A,
    input  [3:0] DIN,
    input  [3:0] SAO,
    output [3:0] DOUT,
    output [3:0] P0,
    output [3:0] P1,
    output [3:0] MUX,
    output PRE_N,
    output SAE,
    output WDEN,
    output [3:0] DQ,
    output [3:0] DQB
);
    wire clkb, ck;
    wire [5:0] aq, an;
    wire weq, wen;
    wire wlen_n, wlen, pre, sen_n, sen, sen1, sen2, muxen, wden_n;
    wire [3:0] p0n, p1n, mxn;
    wire [17:0] t;

    // clock: one buffer for the logic (clkb), one for the flip-flops (ck)
    // (internal names must differ from the ports in more than upper / lower case: SPICE ignores case)
    BUFX4    ubclk (.A(CLK), .Y(clkb), .vdd(vdd), .gnd(gnd));
    CLKBUF1  ubck  (.A(CLK), .Y(ck), .vdd(vdd), .gnd(gnd));

    // input registers (CLK rise)
    DFFPOSX1 ra0 (.D(A[0]), .CLK(ck), .Q(aq[0]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 ra1 (.D(A[1]), .CLK(ck), .Q(aq[1]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 ra2 (.D(A[2]), .CLK(ck), .Q(aq[2]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 ra3 (.D(A[3]), .CLK(ck), .Q(aq[3]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 ra4 (.D(A[4]), .CLK(ck), .Q(aq[4]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 ra5 (.D(A[5]), .CLK(ck), .Q(aq[5]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 rwe (.D(WE),   .CLK(ck), .Q(weq), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 rd0 (.D(DIN[0]), .CLK(ck), .Q(DQ[0]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 rd1 (.D(DIN[1]), .CLK(ck), .Q(DQ[1]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 rd2 (.D(DIN[2]), .CLK(ck), .Q(DQ[2]), .vdd(vdd), .gnd(gnd));
    DFFPOSX1 rd3 (.D(DIN[3]), .CLK(ck), .Q(DQ[3]), .vdd(vdd), .gnd(gnd));

    // complements
    INVX1 ia0 (.A(aq[0]), .Y(an[0]), .vdd(vdd), .gnd(gnd));
    INVX1 ia1 (.A(aq[1]), .Y(an[1]), .vdd(vdd), .gnd(gnd));
    INVX1 ia2 (.A(aq[2]), .Y(an[2]), .vdd(vdd), .gnd(gnd));
    INVX1 ia3 (.A(aq[3]), .Y(an[3]), .vdd(vdd), .gnd(gnd));
    INVX1 ia4 (.A(aq[4]), .Y(an[4]), .vdd(vdd), .gnd(gnd));
    INVX1 ia5 (.A(aq[5]), .Y(an[5]), .vdd(vdd), .gnd(gnd));
    INVX1 iwe (.A(weq), .Y(wen), .vdd(vdd), .gnd(gnd));
    INVX1 id0 (.A(DQ[0]), .Y(DQB[0]), .vdd(vdd), .gnd(gnd));
    INVX1 id1 (.A(DQ[1]), .Y(DQB[1]), .vdd(vdd), .gnd(gnd));
    INVX1 id2 (.A(DQ[2]), .Y(DQB[2]), .vdd(vdd), .gnd(gnd));
    INVX1 id3 (.A(DQ[3]), .Y(DQB[3]), .vdd(vdd), .gnd(gnd));

    // delay chain (BUFX2 x 18): CLK_D1 = t[11] (word line on, precharge hold), CLK_D3 = t[17] (read sense)
    BUFX2 d0 (.A(clkb), .Y(t[0]), .vdd(vdd), .gnd(gnd));
    BUFX2 d1 (.A(t[0]), .Y(t[1]), .vdd(vdd), .gnd(gnd));
    BUFX2 d2 (.A(t[1]), .Y(t[2]), .vdd(vdd), .gnd(gnd));
    BUFX2 d3 (.A(t[2]), .Y(t[3]), .vdd(vdd), .gnd(gnd));
    BUFX2 d4 (.A(t[3]), .Y(t[4]), .vdd(vdd), .gnd(gnd));
    BUFX2 d5 (.A(t[4]), .Y(t[5]), .vdd(vdd), .gnd(gnd));
    BUFX2 d6 (.A(t[5]), .Y(t[6]), .vdd(vdd), .gnd(gnd));
    BUFX2 d7 (.A(t[6]), .Y(t[7]), .vdd(vdd), .gnd(gnd));
    BUFX2 d8 (.A(t[7]), .Y(t[8]), .vdd(vdd), .gnd(gnd));
    BUFX2 d9 (.A(t[8]), .Y(t[9]), .vdd(vdd), .gnd(gnd));
    BUFX2 d10 (.A(t[9]), .Y(t[10]), .vdd(vdd), .gnd(gnd));
    BUFX2 d11 (.A(t[10]), .Y(t[11]), .vdd(vdd), .gnd(gnd));
    BUFX2 d12 (.A(t[11]), .Y(t[12]), .vdd(vdd), .gnd(gnd));
    BUFX2 d13 (.A(t[12]), .Y(t[13]), .vdd(vdd), .gnd(gnd));
    BUFX2 d14 (.A(t[13]), .Y(t[14]), .vdd(vdd), .gnd(gnd));
    BUFX2 d15 (.A(t[14]), .Y(t[15]), .vdd(vdd), .gnd(gnd));
    BUFX2 d16 (.A(t[15]), .Y(t[16]), .vdd(vdd), .gnd(gnd));
    BUFX2 d17 (.A(t[16]), .Y(t[17]), .vdd(vdd), .gnd(gnd));

    // WL_EN = CLK & CLK_D1
    NAND2X1 gwl  (.A(clkb), .B(t[11]), .Y(wlen_n), .vdd(vdd), .gnd(gnd));
    INVX2   iwl  (.A(wlen_n), .Y(wlen), .vdd(vdd), .gnd(gnd));

    // row predecode: P0 from A[1:0], P1 from A[3:2] gated by WL_EN
    NAND2X1 n00 (.A(an[1]), .B(an[0]), .Y(p0n[0]), .vdd(vdd), .gnd(gnd));
    NAND2X1 n01 (.A(an[1]), .B(aq[0]), .Y(p0n[1]), .vdd(vdd), .gnd(gnd));
    NAND2X1 n02 (.A(aq[1]), .B(an[0]), .Y(p0n[2]), .vdd(vdd), .gnd(gnd));
    NAND2X1 n03 (.A(aq[1]), .B(aq[0]), .Y(p0n[3]), .vdd(vdd), .gnd(gnd));
    INVX2   i00 (.A(p0n[0]), .Y(P0[0]), .vdd(vdd), .gnd(gnd));
    INVX2   i01 (.A(p0n[1]), .Y(P0[1]), .vdd(vdd), .gnd(gnd));
    INVX2   i02 (.A(p0n[2]), .Y(P0[2]), .vdd(vdd), .gnd(gnd));
    INVX2   i03 (.A(p0n[3]), .Y(P0[3]), .vdd(vdd), .gnd(gnd));
    NAND3X1 n10 (.A(an[3]), .B(an[2]), .C(wlen), .Y(p1n[0]), .vdd(vdd), .gnd(gnd));
    NAND3X1 n11 (.A(an[3]), .B(aq[2]), .C(wlen), .Y(p1n[1]), .vdd(vdd), .gnd(gnd));
    NAND3X1 n12 (.A(aq[3]), .B(an[2]), .C(wlen), .Y(p1n[2]), .vdd(vdd), .gnd(gnd));
    NAND3X1 n13 (.A(aq[3]), .B(aq[2]), .C(wlen), .Y(p1n[3]), .vdd(vdd), .gnd(gnd));
    INVX2   i10 (.A(p1n[0]), .Y(P1[0]), .vdd(vdd), .gnd(gnd));
    INVX2   i11 (.A(p1n[1]), .Y(P1[1]), .vdd(vdd), .gnd(gnd));
    INVX2   i12 (.A(p1n[2]), .Y(P1[2]), .vdd(vdd), .gnd(gnd));
    INVX2   i13 (.A(p1n[3]), .Y(P1[3]), .vdd(vdd), .gnd(gnd));

    // PRE_N = CLK | CLK_D1  (precharge starts only after the word line is off)
    NOR2X1 gpre (.A(clkb), .B(t[11]), .Y(pre), .vdd(vdd), .gnd(gnd));
    INVX8  ipre (.A(pre), .Y(PRE_N), .vdd(vdd), .gnd(gnd));

    // read sense start: SEN_N = ~(CLK & CLK_D3 & ~WE)
    NAND3X1 gsen (.A(clkb), .B(t[17]), .C(wen), .Y(sen_n), .vdd(vdd), .gnd(gnd));

    // column mux: open from WL_EN until the read sense starts (read) or CLK falls (write)
    AND2X2  gmux (.A(wlen), .B(sen_n), .Y(muxen), .vdd(vdd), .gnd(gnd));
    NAND3X1 m0 (.A(an[5]), .B(an[4]), .C(muxen), .Y(mxn[0]), .vdd(vdd), .gnd(gnd));
    NAND3X1 m1 (.A(an[5]), .B(aq[4]), .C(muxen), .Y(mxn[1]), .vdd(vdd), .gnd(gnd));
    NAND3X1 m2 (.A(aq[5]), .B(an[4]), .C(muxen), .Y(mxn[2]), .vdd(vdd), .gnd(gnd));
    NAND3X1 m3 (.A(aq[5]), .B(aq[4]), .C(muxen), .Y(mxn[3]), .vdd(vdd), .gnd(gnd));
    INVX2   im0 (.A(mxn[0]), .Y(MUX[0]), .vdd(vdd), .gnd(gnd));
    INVX2   im1 (.A(mxn[1]), .Y(MUX[1]), .vdd(vdd), .gnd(gnd));
    INVX2   im2 (.A(mxn[2]), .Y(MUX[2]), .vdd(vdd), .gnd(gnd));
    INVX2   im3 (.A(mxn[3]), .Y(MUX[3]), .vdd(vdd), .gnd(gnd));

    // SAE: a few gates after SEN_N, so the column mux is already closed when the sense amps fire
    INVX1   gse0 (.A(sen_n), .Y(sen), .vdd(vdd), .gnd(gnd));
    BUFX2   gse1 (.A(sen), .Y(sen1), .vdd(vdd), .gnd(gnd));
    BUFX2   gse2 (.A(sen1), .Y(sen2), .vdd(vdd), .gnd(gnd));
    BUFX4   gse3 (.A(sen2), .Y(SAE), .vdd(vdd), .gnd(gnd));

    // WDEN = WL_EN & WE
    NAND2X1 gwd (.A(wlen), .B(weq), .Y(wden_n), .vdd(vdd), .gnd(gnd));
    INVX4   iwd (.A(wden_n), .Y(WDEN), .vdd(vdd), .gnd(gnd));

    // output registers (CLK fall): read data, or the written data in a write cycle
    DFFNEGX1 rq0 (.D(SAO[0]), .CLK(ck), .Q(DOUT[0]), .vdd(vdd), .gnd(gnd));
    DFFNEGX1 rq1 (.D(SAO[1]), .CLK(ck), .Q(DOUT[1]), .vdd(vdd), .gnd(gnd));
    DFFNEGX1 rq2 (.D(SAO[2]), .CLK(ck), .Q(DOUT[2]), .vdd(vdd), .gnd(gnd));
    DFFNEGX1 rq3 (.D(SAO[3]), .CLK(ck), .Q(DOUT[3]), .vdd(vdd), .gnd(gnd));
endmodule
