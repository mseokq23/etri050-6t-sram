#!/usr/bin/env python3
"""sram64x4 chip top on the kit's 28-pin pad frame.

  make_top.py <work dir>          (run_chip.sh calls it)

  writes into <work dir>
    sram64x4_Top.mag     copy of the kit's pad frame template with the pad cells this chip needs
    chip_routes.tcl      Magic procs: place_core, draw_routes, pad_labels
    chipnet_top.spice    the connections the routes have to make (check_chip.sh compares them)
  and prints the pad table

  the pad frame and the pad pins are read from the kit at run time (nothing of the kit is stored here)
    $ETRI050_PADS/MPW_PAD_28Pin_IO.mag   28 PIC pads PAD_0 .. PAD_27, counter-clockwise from the bottom left
    $ETRI050_PADS/GDS_Magic/<cell>.mag   the metal2 pin on the core side of each pad cell
  package pin of PAD_k = (k + 7) % 28 + 1, the same as the kit's MPW_PAD_28Pin_IO_Games.mag
  (VDD on pins 1 and 8, GND on pins 14 and 21 there, so this chip keeps those four places)

  routes (all numbers in um, chip coordinates)
    signals: metal2 only, 3.2 um wide, no crossings (left pads go down outside, right pads too,
             tracks under the macro, one short drop into each macro pin)
    VDD / VSS from the top pads: 30 um metal2 down onto the top end of the macro's VDD / VSS line
    VDD / VSS from the bottom pads: 30 um metal3 over the signal tracks, 4 x 4 vias on the pad side,
             4 vias on the macro's VDD / VSS line; every via 3 lambda inside both metals
"""
import os
import sys

LAM = 0.3                      # um per lambda
OX, OY = 837.0, 870.0          # where the macro's (0, 0) goes (a multiple of lambda)
W = 3.2                        # signal wire width (= the pad pin width)
VIA = 2.1                      # via (m3contact) 7 x 7 lambda

MACRO_PINS = ["A[0]", "A[1]", "A[2]", "A[3]", "A[4]", "A[5]", "WE", "CLK",
              "DIN[0]", "DIN[1]", "DIN[2]", "DIN[3]", "DOUT[0]", "DOUT[1]", "DOUT[2]", "DOUT[3]"]

# PAD_k: (pad cell, net). The pads not listed stay PIC (input, not connected).
PADS = {
    21: ("PVDD", "VDD"),
    22: ("PIC", "A[0]"), 23: ("PIC", "A[1]"), 24: ("PIC", "A[2]"),
    25: ("PIC", "A[3]"), 26: ("PIC", "A[4]"), 27: ("PIC", "A[5]"),
    0: ("PVDD", "VDD"),
    1: ("PIC", "WE"), 2: ("PIC", "CLK"), 3: ("PIC", "DIN[0]"), 4: ("PIC", "DIN[1]"), 5: ("PIC", "DIN[2]"),
    6: ("PVSS", "VSS"),
    7: ("PIC", "DIN[3]"), 8: ("POB8", "DOUT[0]"), 9: ("POB8", "DOUT[1]"),
    10: ("POB8", "DOUT[2]"), 11: ("POB8", "DOUT[3]"),
    13: ("PVSS", "VSS"),
}


def lam(v):
    """macro lambda -> chip um (x and y use the same scale; add OX or OY outside)"""
    return LAM * v


# macro geometry used here (from layout/macro.tcl, in macro lambda)
def macro_pin_x(n):                     # pins: metal2 4 lambda wide at x -193 + 70 n, bottom at y -1030
    x0 = OX + lam(-193 + 70 * n)
    return x0, x0 + lam(4)


Y_PIN_BOTTOM = OY + lam(-1030)          # bottom edge of the macro (and of its pins)
Y_PIN_TOP = OY + lam(-1026)             # drops overlap the pins by 4 lambda
LEFT_VDD = (OX + lam(-234), OX + lam(-221))    # left VDD line (metal2), top end y 985
RIGHT_VSS = (OX + lam(975), OX + lam(988))     # right VSS line (metal2), top end y 968
VDD_NECK_Y0 = OY + lam(972)             # metal1 VDD line on top of the macro: y 972 .. 985
VSS_NECK_Y0 = OY + lam(955)             # metal1 VSS line on top of the macro: y 955 .. 968


def magscale_unit(lines):
    for ln in lines:
        if ln.startswith("magscale"):
            a, b = map(int, ln.split()[1:3])
            return LAM * a / b
    raise SystemExit("no magscale line")


def read_frame(path):
    lines = open(path).read().split("\n")
    unit = magscale_unit(lines)
    pads = {}
    for i, ln in enumerate(lines):
        p = ln.split()
        if len(p) >= 3 and p[0] == "use" and p[2].startswith("PAD_"):
            t = next(s for s in lines[i + 1:i + 4] if s.startswith("transform"))
            pads[int(p[2][4:])] = (i, p[1], [int(v) for v in t.split()[1:]])
    if sorted(pads) != list(range(28)):
        raise SystemExit(f"{path}: expected PAD_0 .. PAD_27")
    return lines, unit, pads


def read_pin(cell):
    """the metal2 rectangle in the pad cell itself (the core side end of its pin), in um"""
    path = os.path.join(os.environ["ETRI050_PADS"], "GDS_Magic", cell + ".mag")
    lines = open(path).read().split("\n")
    unit = magscale_unit(lines)
    rects, on = [], False
    for ln in lines:
        if ln.startswith("<< "):
            on = ln.strip() == "<< metal2 >>"
        elif ln.startswith("use "):
            on = False
        elif on and ln.startswith("rect"):
            rects.append([unit * int(v) for v in ln.split()[1:5]])
    if len(rects) != 1:
        raise SystemExit(f"{path}: expected one metal2 rectangle, found {len(rects)}")
    return rects[0]


def place(rect, tr, unit):
    a, b, c, d, e, f = tr
    xs, ys = [], []
    for x, y in ((rect[0], rect[1]), (rect[2], rect[3])):
        xs.append(a * x + b * y + c * unit)
        ys.append(d * x + e * y + f * unit)
    return [round(min(xs), 3), round(min(ys), 3), round(max(xs), 3), round(max(ys), 3)]


def side(k):
    return "bottom" if k <= 6 else "right" if k <= 13 else "top" if k <= 20 else "left"


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    work = sys.argv[1]
    frame = os.path.join(os.environ["ETRI050_PADS"], "MPW_PAD_28Pin_IO.mag")
    lines, unit, pads = read_frame(frame)

    # ---- pad frame: change the pad cells -------------------------------------------------------
    for k, (cell, _net) in PADS.items():
        i, old, _tr = pads[k]
        if old != "PIC":
            raise SystemExit(f"PAD_{k} is {old}, expected PIC")
        lines[i] = lines[i].replace("use PIC", "use " + cell, 1)
    with open(os.path.join(work, "sram64x4_Top.mag"), "w") as fo:
        fo.write("\n".join(lines))

    pin = {}
    for k in range(28):
        cell = PADS.get(k, ("PIC", ""))[0]
        pin[k] = place(read_pin(cell), pads[k][2], unit)

    print("pad     side    cell  net      package pin   pin on the core side (um)")
    for k in sorted(range(28), key=lambda k: (k + 7) % 28):
        cell, net = PADS.get(k, ("PIC", "-"))
        x0, y0, x1, y1 = pin[k]
        print(f"PAD_{k:<3} {side(k):7} {cell:5} {net:8} {(k + 7) % 28 + 1:>6}        "
              f"({x0:.2f}, {y0:.2f}) - ({x1:.2f}, {y1:.2f})")

    shapes = []

    def rect(layer, x0, y0, x1, y1):
        shapes.append((layer, round(min(x0, x1), 3), round(min(y0, y1), 3),
                       round(max(x0, x1), 3), round(max(y0, y1), 3)))

    def pinx(net):
        return macro_pin_x(MACRO_PINS.index(net))

    h = W / 2

    # ---- left pads: A[0] (top) .. A[5] (bottom) ---------------------------------------------------
    # A[5] (PAD_27) is level with the channel and goes straight; the others go right to a riser,
    # down to a track and right to the pin. Lower pad = riser further out and lower track, so nothing crosses.
    for i, k in enumerate([22, 23, 24, 25, 26, 27]):
        net = PADS[k][1]
        x0, y0, x1, y1 = pin[k]
        p0, p1 = pinx(net)
        if k == 27:
            rect("metal2", x0, y0, p1, y1)
            rect("metal2", p0, y0, p1, Y_PIN_TOP)
            continue
        xr = 470.0 + 12.0 * (4 - i)           # A[4] 470 .. A[0] 518
        yc = 502.4 + 12.0 * (4 - i)           # A[4] 502.4 .. A[0] 550.4
        rect("metal2", x0, y0, xr + h, y1)            # from the pad
        rect("metal2", xr - h, yc - h, xr + h, y1)    # riser
        rect("metal2", xr - h, yc - h, p1, yc + h)    # track
        rect("metal2", p0, yc - h, p1, Y_PIN_TOP)     # into the macro pin

    # ---- bottom pads: up to a track, across, up into the pin ---------------------------------------
    # a pad further from its pin gets the higher track (WE over CLK, DIN[2] over DIN[1] over DIN[0])
    for k, yc in ((1, 468.4), (2, 456.4), (3, 456.4), (4, 468.4), (5, 480.4)):
        net = PADS[k][1]
        x0, y0, x1, y1 = pin[k]
        p0, p1 = pinx(net)
        rect("metal2", x0, y0, x1, yc + h)
        rect("metal2", min(x0, p0), yc - h, max(x1, p1), yc + h)
        rect("metal2", p0, yc - h, p1, Y_PIN_TOP)

    # ---- right pads: DIN[3] (bottom) .. DOUT[3] (top), mirror of the left side ----------------------
    for j, k in enumerate([7, 8, 9, 10, 11]):
        net = PADS[k][1]
        x0, y0, x1, y1 = pin[k]
        p0, p1 = pinx(net)
        xr = 1446.0 - 12.0 * j                # DIN[3] 1446 .. DOUT[3] 1398
        yc = 492.4 + 12.0 * j                 # DIN[3] 492.4 .. DOUT[3] 540.4
        rect("metal2", xr - h, y0, x1, y1)
        rect("metal2", xr - h, yc - h, xr + h, y1)
        rect("metal2", p0, yc - h, xr + h, yc + h)
        rect("metal2", p0, yc - h, p1, Y_PIN_TOP)

    # ---- VDD / VSS from the top corners: metal2 onto the top end of the macro's lines ----------------
    def top_strap(k, bus, neck_y0):
        x0, y0, x1, y1 = pin[k]
        cx = (bus[0] + bus[1]) / 2
        wx0, wx1 = cx - lam(50.5), cx + lam(50.5)     # 30.3 um wide part
        rect("metal2", min(x0, wx0), 1340.1, max(x1, wx1), 1370.1)
        rect("metal2", wx0, 1185.0, wx1, 1370.1)
        rect("metal2", bus[0], neck_y0, bus[1], 1185.0)    # as wide as the macro line

    top_strap(21, LEFT_VDD, VDD_NECK_Y0)
    top_strap(13, RIGHT_VSS, VSS_NECK_Y0)

    # ---- VDD / VSS from the bottom corners: metal3 over the signal tracks ----------------------------
    def bottom_strap(k, bus, mx0):
        x0, y0, x1, y1 = pin[k]
        rect("metal2", x0, y0, x1, 480.0)                         # from the pad, under the tracks
        rect("metal3", mx0, 446.4, mx0 + 30.0, 606.0)             # up across the tracks
        rect("metal3", min(mx0, bus[0]), 576.0, max(mx0 + 30.0, bus[1]), 606.0)   # over to the macro line
        for i in range(4):
            for j in range(4):
                vx, vy = mx0 + 4.8 + 6.0 * i, 450.0 + 6.0 * j
                rect("m3contact", vx, vy, vx + VIA, vy + VIA)
        for j in range(4):
            vx, vy = bus[0] + lam(3), 579.0 + 6.0 * j
            rect("m3contact", vx, vy, vx + VIA, vy + VIA)

    bottom_strap(0, LEFT_VDD, 531.0)
    bottom_strap(6, RIGHT_VSS, 1338.0)

    # ---- Magic procs -------------------------------------------------------------------------------
    tcl = ["# written by chip/make_top.py (core origin, routes, pad pin labels)",
           "proc place_core {cell} {",
           f"  getcell $cell child 0 0 parent {OX}um {OY}um",
           "}",
           "proc draw_routes {} {"]
    for layer, x0, y0, x1, y1 in shapes:
        tcl.append(f"  box {x0}um {y0}um {x1}um {y1}um; paint {layer}")
    tcl.append("}")
    tcl.append("proc pad_labels {} {")
    for k, (cell, net) in sorted(PADS.items()):
        x0, y0, x1, y1 = pin[k]
        cx, cy = round((x0 + x1) / 2, 3), round((y0 + y1) / 2, 3)
        tcl.append(f"  box {cx}um {cy}um {cx}um {cy}um; label {{{net}}} c metal2")   # braces: A[0] is not a Tcl command
    tcl.append("}")
    with open(os.path.join(work, "chip_routes.tcl"), "w") as fo:
        fo.write("\n".join(tcl) + "\n")

    ports = ["VDD", "VSS", "CLK", "WE"] + [f"A[{i}]" for i in range(6)] + \
            [f"DIN[{i}]" for i in range(4)] + [f"DOUT[{i}]" for i in range(4)]
    with open(os.path.join(work, "chipnet_top.spice"), "w") as fo:
        fo.write("* pad pins -> macro pins (written by chip/make_top.py)\n")
        fo.write(".subckt sram64x4_chipnet " + " ".join(ports) + "\n")
        fo.write("X0 " + " ".join(ports) + " sram64x4\n.ends\n")

    n2 = sum(1 for s in shapes if s[0] == "metal2")
    n3 = sum(1 for s in shapes if s[0] == "metal3")
    nv = sum(1 for s in shapes if s[0] == "m3contact")
    print(f"routes: {n2} metal2, {n3} metal3, {nv} vias; core origin ({OX}, {OY}) um")


if __name__ == "__main__":
    main()
