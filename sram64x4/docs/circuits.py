#!/usr/bin/env python3
"""Circuit pictures of the part 2 peripheral circuits (sim/periph.spice) for the posts.

  python3 sram64x4/docs/circuits.py        (pip install schemdraw)
    -> docs/img/04/rowdrv.png, 06/pchg_cmux.png, 07/sa.png, 09/wdrv.png
  W/L in um, the same numbers as sim/periph.spice
"""
import os

import schemdraw
import schemdraw.elements as elm
import schemdraw.logic as logic

schemdraw.use("matplotlib")
IMG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "img")


def out(post, name):
    os.makedirs(os.path.join(IMG, post), exist_ok=True)
    return os.path.join(IMG, post, name)


def tag(d, q, text, left=False):
    """device name and W/L beside the transistor"""
    y = (q.drain.y + q.source.y) / 2
    if left:
        x = min(q.drain.x, q.source.x) - 0.25
        d.add(elm.Label().at((x, y)).label(text, halign="right", fontsize=10))
    else:
        x = max(q.drain.x, q.source.x) + 0.25
        d.add(elm.Label().at((x, y)).label(text, halign="left", fontsize=10))


def pin(d, at, name, side):
    d.add(elm.Dot(open=True).at(at).label(name, side))


def pchg_cmux(fn):
    with schemdraw.Drawing(file=fn, show=False, dpi=120) as d:
        d.config(fontsize=11, unit=1.2)
        for i, (bl, dl, n1, n2) in enumerate((("BL", "DL", "MPC1", "MNM1"), ("BLB", "DLB", "MPC2", "MNM2"))):
            x = 6.0 * i
            p = d.add(elm.PFet().theta(0).reverse().anchor("source").at((x, 6)))
            tag(d, p, f"{n1}  3.6/0.6")
            d.add(elm.Line().at(p.source).up(0.6))
            d.add(elm.Vdd().label("VDD"))
            d.add(elm.Line().at(p.gate).left(0.6))
            pin(d, d.here, "PRE_N", "left")
            d.add(elm.Line().at(p.drain).down(1.0))
            nb = d.add(elm.Dot().label(f"{bl}[c]", "right"))
            d.add(elm.Line().at(nb.center).left(1.4).label("16 cells", "top", fontsize=9))
            n = d.add(elm.NFet().theta(0).reverse().anchor("drain").at(nb.center))
            tag(d, n, f"{n2}  3.6/0.6")
            d.add(elm.Line().at(n.gate).left(0.6))
            pin(d, d.here, "MUX[k]", "left")
            d.add(elm.Line().at(n.source).down(0.6))
            pin(d, d.here, f"{dl}[b]", "bottom")


def wdrv(fn):
    with schemdraw.Drawing(file=fn, show=False, dpi=120) as d:
        d.config(fontsize=11, unit=1.2)
        for i, (dl, g, n1, n2) in enumerate((("DL", "DQB", "MW1", "MW2"), ("DLB", "DQ", "MW3", "MW4"))):
            x = 6.0 * i
            pin(d, (x, 6), dl + "[b]", "top")
            a = d.add(elm.NFet().theta(0).reverse().anchor("drain").at((x, 5.4)))
            d.add(elm.Line().at((x, 6)).to(a.drain))
            tag(d, a, f"{n1}  4.8/0.6")
            d.add(elm.Line().at(a.gate).left(0.6))
            pin(d, d.here, "WDEN", "left")
            b = d.add(elm.NFet().theta(0).reverse().anchor("drain").at(a.source))
            tag(d, b, f"{n2}  4.8/0.6")
            d.add(elm.Line().at(b.gate).left(0.6))
            pin(d, d.here, f"{g}[b]", "left")
            d.add(elm.Line().at(b.source).down(0.4))
            d.add(elm.Ground())


def sa(fn):
    with schemdraw.Drawing(file=fn, show=False, dpi=120) as d:
        d.config(fontsize=11, unit=1.2)
        top = 9.0
        # latch: left devices gate to the right, right devices gate to the left
        p1 = d.add(elm.PFet().theta(0).anchor("source").at((0, top)))
        n1 = d.add(elm.NFet().theta(0).anchor("drain").at((0, top - 3.2)))
        p2 = d.add(elm.PFet().theta(0).reverse().anchor("source").at((6, top)))
        n2 = d.add(elm.NFet().theta(0).reverse().anchor("drain").at((6, top - 3.2)))
        tag(d, p1, "MP1  2.4/0.6", left=True)
        tag(d, n1, "MN1  3.6/0.6", left=True)
        tag(d, p2, "MP2  2.4/0.6")
        tag(d, n2, "MN2  3.6/0.6")
        d.add(elm.Line().at(p1.drain).to(n1.drain))
        d.add(elm.Line().at(p2.drain).to(n2.drain))
        dl = ((p1.drain.x), (p1.drain.y + n1.drain.y) / 2)
        dlb = ((p2.drain.x), (p2.drain.y + n2.drain.y) / 2)
        d.add(elm.Dot().at(dl))
        d.add(elm.Dot().at(dlb))
        # gates tied, then crossed over to the other side
        d.add(elm.Line().at(p1.gate).to((p1.gate.x, n1.gate.y)))
        d.add(elm.Line().at(n1.gate).to(n1.gate))
        d.add(elm.Line().at(p2.gate).to((p2.gate.x, n2.gate.y)))
        g1 = (p1.gate.x, dl[1])
        g2 = (p2.gate.x, dlb[1])
        d.add(elm.Dot().at(g1))
        d.add(elm.Dot().at(g2))
        d.add(elm.Line().at(g1).to((g1[0] + 0.6, g1[1])))
        d.add(elm.Line().at((g1[0] + 0.6, g1[1])).to((dlb[0] - 0.9, dlb[1] - 0.9)))
        d.add(elm.Line().at((dlb[0] - 0.9, dlb[1] - 0.9)).to((dlb[0], dlb[1] - 0.9)))
        d.add(elm.Line().at((dlb[0], dlb[1] - 0.9)).to(dlb))
        d.add(elm.Line().at(g2).to((g2[0] - 0.6, g2[1])))
        d.add(elm.Line().at((g2[0] - 0.6, g2[1])).to((dl[0] + 0.9, dl[1] + 0.9)))
        d.add(elm.Line().at((dl[0] + 0.9, dl[1] + 0.9)).to((dl[0], dl[1] + 0.9)))
        d.add(elm.Line().at((dl[0], dl[1] + 0.9)).to(dl))
        # VDD rail
        d.add(elm.Line().at(p1.source).to((p1.source.x, top + 0.6)))
        d.add(elm.Line().at(p2.source).to((p2.source.x, top + 0.6)))
        d.add(elm.Line().at((-5.5, top + 0.6)).to((11.5, top + 0.6)))
        d.add(elm.Vdd().at((3, top + 0.6)).label("VDD"))
        # tail
        d.add(elm.Line().at(n1.source).to((n1.source.x, n1.source.y - 0.6)))
        d.add(elm.Line().at(n2.source).to((n2.source.x, n2.source.y - 0.6)))
        d.add(elm.Line().at((n1.source.x, n1.source.y - 0.6)).to((n2.source.x, n2.source.y - 0.6)))
        tail = (3, n1.source.y - 0.6)
        d.add(elm.Dot().at(tail).label("TAIL", "top"))
        t = d.add(elm.NFet().theta(0).reverse().anchor("drain").at(tail))
        tag(d, t, "MNT1, MNT2  2 x 3.6/0.6")
        d.add(elm.Line().at(t.gate).left(0.6))
        pin(d, d.here, "SAE", "left")
        d.add(elm.Line().at(t.source).down(0.4))
        d.add(elm.Ground())
        # DL / DLB precharge
        pp1 = d.add(elm.PFet().theta(0).reverse().anchor("source").at((-4.2, top + 0.6)))
        pp2 = d.add(elm.PFet().theta(0).anchor("source").at((10.2, top + 0.6)))
        tag(d, pp1, "MPP1  2.4/0.6")
        tag(d, pp2, "MPP2  2.4/0.6", left=True)
        d.add(elm.Line().at(pp1.gate).left(0.5))
        pin(d, d.here, "PRE_N", "left")
        d.add(elm.Line().at(pp2.gate).right(0.5))
        pin(d, d.here, "PRE_N", "right")
        d.add(elm.Line().at(pp1.drain).to((pp1.drain.x, dl[1])))
        d.add(elm.Line().at((pp1.drain.x, dl[1])).to(dl))
        d.add(elm.Line().at(pp2.drain).to((pp2.drain.x, dlb[1])))
        d.add(elm.Line().at((pp2.drain.x, dlb[1])).to(dlb))
        # data lines out, output inverter on DLB
        d.add(elm.Line().at((pp1.drain.x, dl[1])).to((-6.0, dl[1])))
        pin(d, (-6.0, dl[1]), "DL[b]", "left")
        d.add(elm.Line().at((pp2.drain.x, dlb[1])).to((12.6, dlb[1])))
        d.add(elm.Dot(open=True).at((11.6, dlb[1])).label("DLB[b]", "bottom"))
        inv = d.add(logic.Not().at((12.6, dlb[1])).right())
        d.add(elm.Line().at(inv.out).right(0.4))
        pin(d, d.here, "SAO[b]", "right")
        d.add(elm.Label().at((13.9, dlb[1] + 1.1)).label("SAO = not DLB  (P 3.6/0.6, N 1.8/0.6)\nthe same inverter on DL as a dummy load", fontsize=9))
        d.add(elm.Label().at((dl[0] - 0.35, dl[1] + 0.35)).label("DL", fontsize=10, halign="right"))
        d.add(elm.Label().at((dlb[0] + 0.35, dlb[1] + 0.35)).label("DLB", fontsize=10, halign="left"))


def rowdrv(fn):
    with schemdraw.Drawing(file=fn, show=False, dpi=120) as d:
        d.config(fontsize=11, unit=1.2)
        g = d.add(logic.Nand(inputs=2).right())
        d.add(elm.Line().at(g.in1).left(0.8))
        pin(d, d.here, "P0[r % 4]", "left")
        d.add(elm.Line().at(g.in2).left(0.8))
        pin(d, d.here, "P1[r / 4]", "left")
        d.add(elm.Line().at(g.out).right(1.0).label("X", "top"))
        i = d.add(logic.Not().right())
        d.add(elm.Line().at(i.out).right(1.2))
        d.add(elm.Dot().label("WL[r]", "top"))
        d.add(elm.Line().right(1.0).label("16 cells", "bottom", fontsize=9))
        d.add(elm.Label().at(((g.in1.x + g.out.x) / 2, min(g.in1.y, g.in2.y) - 1.2)).label(
            "NAND2\nP 5.1/0.6 x 2 (parallel)\nN 4.5/0.6 x 2 (series)", fontsize=9))
        d.add(elm.Label().at(((i.in1.x + i.out.x) / 2, i.out.y - 1.6)).label(
            "INV, 2 fingers\nP 2 x 5.1/0.6\nN 2 x 4.5/0.6", fontsize=9))


if __name__ == "__main__":
    rowdrv(out("04", "rowdrv.png"))
    pchg_cmux(out("06", "pchg_cmux.png"))
    sa(out("07", "sa.png"))
    wdrv(out("09", "wdrv.png"))
    print("docs/img/04/rowdrv.png 06/pchg_cmux.png 07/sa.png 09/wdrv.png")
