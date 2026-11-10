#!/usr/bin/env python3
"""Pictures for the part 2 posts that are not tool screenshots.

  python3 sram64x4/docs/figures.py
    -> docs/img/03/block.png      blocks of the macro and the lines between them
       docs/img/03/timing.png     one write and one read cycle (sim/sch16_out.txt from scripts/run_pex.sh)
       docs/img/16/floorplan.png  where the blocks sit in the macro (lambda, numbers from the layout scripts)
"""
import os

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

HERE = os.path.dirname(os.path.abspath(__file__))
IMG = os.path.join(HERE, "img")
SIM = os.path.join(HERE, "..", "sim")


def save(fig, post, name):
    os.makedirs(os.path.join(IMG, post), exist_ok=True)
    fig.savefig(os.path.join(IMG, post, name))
    plt.close(fig)


def block():
    fig, ax = plt.subplots(figsize=(10, 7.2), dpi=110)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 72)
    ax.axis("off")

    def box(x, y, w, h, title, sub, color):
        ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.3", fc=color, ec="black", lw=1.2))
        ax.text(x + w / 2, y + h / 2 + (1.6 if sub else 0), title, ha="center", va="center", fontsize=11, weight="bold")
        if sub:
            ax.text(x + w / 2, y + h / 2 - 2.2, sub, ha="center", va="center", fontsize=9)

    def arrow(x0, y0, x1, y1, text="", tx=0, ty=0, ha="center"):
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0), arrowprops=dict(arrowstyle="->", lw=1.3))
        if text:
            ax.text((x0 + x1) / 2 + tx, (y0 + y1) / 2 + ty, text, ha=ha, va="center", fontsize=9, color="navy")

    box(38, 44, 50, 24, "cell array 16 x 16", "256 x sram6t (part 1 cell)\nrow r, column c", "#e8f0ff")
    box(18, 44, 16, 24, "row decoder", "16 x (NAND2 + WL driver)", "#fff3d6")
    box(38, 30, 50, 9, "column periphery", "16 x precharge + 4:1 column mux (NMOS)", "#e9f7e9")
    box(38, 17, 50, 9, "sense amp + write driver", "x 4 (one per bit)", "#fde8e8")
    box(10, 2, 78, 10, "control block (kit standard cells)", "input registers, predecoder, timing (WL_EN, PRE_N, MUX, SAE, WDEN), output registers", "#eeeeee")

    arrow(34, 56, 38, 56, "WL[15:0]", ty=2.6)
    arrow(63, 44, 63, 39, "BL / BLB [15:0]", tx=8)
    arrow(63, 30, 63, 26, "DL / DLB [3:0]", tx=8)
    arrow(26, 12, 26, 44, "P0[3:0], P1[3:0]", tx=-1, ha="right")
    ax.plot([35.5, 35.5], [12, 34.5], color="black", lw=1.3)
    arrow(35.5, 34.5, 38, 34.5)
    ax.text(35, 22, "PRE_N,\nMUX[3:0]", ha="right", va="center", fontsize=9, color="navy")
    arrow(52, 12, 52, 17, "SAE, WDEN,\nDQ / DQB", tx=1, ha="left", ty=0)
    arrow(80, 17, 80, 12, "SAO[3:0]", tx=1, ha="left")

    pins = ["CLK", "WE", "A[5:0]", "DIN[3:0]"]
    for i, p in enumerate(pins):
        x = 14 + 12 * i
        ax.annotate("", xy=(x, 2), xytext=(x, -3), arrowprops=dict(arrowstyle="->", lw=1.1), annotation_clip=False)
        ax.text(x, -4.5, p, ha="center", va="top", fontsize=10)
    ax.annotate("", xy=(78, -3), xytext=(78, 2), arrowprops=dict(arrowstyle="->", lw=1.1), annotation_clip=False)
    ax.text(78, -4.5, "DOUT[3:0]", ha="center", va="top", fontsize=10)
    ax.text(95, 56, "A[3:0]\n= row", ha="center", fontsize=9)
    ax.text(95, 34, "A[5:4]\n= column\nin the group", ha="center", fontsize=9)
    ax.set_title("sram64x4: 64 words x 4 bits", fontsize=13)
    fig.subplots_adjust(bottom=0.1, top=0.93, left=0.02, right=0.98)
    save(fig, "03", "block.png")


def timing():
    d = np.loadtxt(os.path.join(SIM, "sch16_out.txt"))
    t = d[:, 0] * 1e9
    T = 50.0
    # cycle 15 = last write (address 15 + 16 * 3 = 63, row 15), cycle 16 = first read (address 0, row 0)
    t0, t1 = 15 * T + 15, 17 * T + 30
    m = (t >= t0) & (t <= t1)
    col = {"CLK": 1, "WE": 2, "DOUT[0]": 3}
    wl15, wl0 = 7 + 15, 7 + 0
    sae, pre, dl, dlb = 23, 24, 25, 26
    rows = [("CLK", d[:, 1], "black"), ("WE", d[:, 2], "black"),
            ("WL[15] (write row)", d[:, wl15], "tab:blue"), ("WL[0] (read row)", d[:, wl0], "tab:blue"),
            ("PRE_N", d[:, pre], "tab:green"), ("SAE", d[:, sae], "tab:red"),
            ("DL[0] / DLB[0]", (d[:, dl], d[:, dlb]), "tab:purple"), ("DOUT[0]", d[:, 3], "black")]
    fig, axs = plt.subplots(len(rows), 1, figsize=(10, 8), dpi=110, sharex=True)
    for ax, (name, v, c) in zip(axs, rows):
        if isinstance(v, tuple):
            ax.plot(t[m], v[0][m], color=c, lw=1.2)
            ax.plot(t[m], v[1][m], color=c, lw=1.2, ls="--")
        else:
            ax.plot(t[m], v[m], color=c, lw=1.2)
        ax.set_ylim(-0.5, 5.5)
        ax.set_yticks([])
        ax.set_ylabel(name, rotation=0, ha="right", va="center", fontsize=9)
        for k in (15, 16, 17):
            ax.axvline(k * T + T / 2, color="gray", lw=0.6, ls=":")
        ax.grid(axis="x", alpha=0.3)
    axs[0].text(15 * T + T / 2 + 1, 6.2, "write cycle (address 63)", fontsize=9)
    axs[0].text(16 * T + T / 2 + 1, 6.2, "read cycle (address 0)", fontsize=9)
    axs[-1].set_xlabel("t [ns]   (schematic netlist, T = 50 ns, nominal model)")
    fig.subplots_adjust(left=0.16, right=0.98, top=0.95, bottom=0.07, hspace=0.15)
    save(fig, "03", "timing.png")


def floorplan():
    from matplotlib.patches import Rectangle
    fig, ax = plt.subplots(figsize=(7.6, 10.4), dpi=110)
    blocks = [  # name, x0, y0, x1, y1 (macro lambda), color
        ("cell array 16 x 16\n(0, 0) .. (960, 944)", 0, 0, 960, 944, "#e8f0ff"),
        ("row\ndecoder", -149, -3, 0, 947, "#fff3d6"),
        ("P0 / P1\nlines", -193, -3, -149, 947, "#fff9ea"),
        ("column periphery (precharge + mux), y -128 .. -3", -40, -128, 960, -3, "#e9f7e9"),
        ("sense amps + write drivers, y -274 .. -134", -40, -274, 960, -134, "#fde8e8"),
        ("control block (standard cells, OpenROAD)\n(-206, -990) .. (964, -290)", -206, -990, 964, -290, "#eeeeee"),
    ]
    for name, x0, y0, x1, y1, col in blocks:
        ax.add_patch(Rectangle((x0, y0), x1 - x0, y1 - y0, fc=col, ec="black", lw=1.0))
        ax.text((x0 + x1) / 2, (y0 + y1) / 2, name, ha="center", va="center", fontsize=8.5,
                rotation=90 if x1 - x0 < 100 else 0)
    for x0, x1, net in ((-251, -238, "VSS"), (-234, -221, "VDD"), (975, 988, "VSS"), (992, 1005, "VDD")):
        ax.add_patch(Rectangle((x0, -1024), x1 - x0, 2009, fc="#9ab" if net == "VSS" else "#d97", ec="none"))
    for y0, y1, net in ((955, 968, "VSS"), (972, 985, "VDD"), (-1007, -994, "VSS"), (-1024, -1011, "VDD")):
        ax.add_patch(Rectangle((-251, y0), 1256, y1 - y0, fc="#9ab" if net == "VSS" else "#d97", ec="none", alpha=0.7))
    for n in range(16):
        x = -193 + 70 * n
        ax.add_patch(Rectangle((x, -1030), 4, 48, fc="black"))
    ax.text(330, -1080, "16 pins on metal2 at the bottom edge (x = -193 + 70 n)", ha="center", fontsize=8.5)
    ax.text(-236, 1010, "VSS / VDD lines (metal2 left, right; metal1 top, bottom)", fontsize=8.5)
    ax.set_xlim(-300, 1060)
    ax.set_ylim(-1120, 1060)
    ax.set_aspect("equal")
    ax.set_xlabel("x [lambda]  (1 lambda = 0.3 um)")
    ax.set_ylabel("y [lambda]")
    ax.set_title("sram64x4 floorplan: 1256 x 2015 lambda = 377 x 605 um", fontsize=11)
    ax.grid(alpha=0.2)
    fig.tight_layout()
    save(fig, "16", "floorplan.png")


if __name__ == "__main__":
    block()
    floorplan()
    if os.path.exists(os.path.join(SIM, "sch16_out.txt")):
        timing()
    print("docs/img/03/block.png, timing.png, 16/floorplan.png")
