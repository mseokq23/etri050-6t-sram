#!/usr/bin/env python3
"""Part 1 6T cell at the kit's process corners: hold SNM, read SNM, write trip voltage.

  python3 sram64x4/scripts/cell_corners.py
    -> sram64x4/sim/cell_corners.txt   table
       sram64x4/sim/cell_corners.png   read butterfly curves at the five corners (5 V)

  same circuits and sizes as part 1 sim/butterfly.spice and sim/write_trip.spice,
  models from sram64x4/work/corner.lib (scripts/corner_lib.sh), decks and data in sram64x4/work/cell_corners
  the kit's corner file has no temperature parameters, so only the process corners and the supply change
"""
import os
import re
import subprocess
import sys

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

S = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))        # sram64x4/
sys.path.insert(0, os.path.join(S, "..", "scripts"))
from snm import load, snm                                               # noqa: E402  (part 1 script)

LIB = os.path.join(S, "work", "corner.lib")
WORK = os.path.join(S, "work", "cell_corners")
CASES = [("TT", 5.0), ("SS", 5.0), ("FF", 5.0), ("SF", 5.0), ("FS", 5.0), ("SS", 4.5), ("FF", 5.5)]
SIZES = ".param wpu=1.8u wpd=3.6u wpg=1.8u lch=0.6u"

BUTTERFLY = """* butterfly (part 1 sim/butterfly.spice) at {c}, VDD = {v} V
.lib {lib} {c}
{sizes}
VDD vdd 0 {v}
VBL bl  0 {v}
VWL wl  0 0
VIN x   0 0
MPUA qa x vdd vdd pfet W={{wpu}} L={{lch}}
MPDA qa x 0   0   nfet W={{wpd}} L={{lch}}
MPGA bl wl qa 0   nfet W={{wpg}} L={{lch}}
MPUB qb x vdd vdd pfet W={{wpu}} L={{lch}}
MPDB qb x 0   0   nfet W={{wpd}} L={{lch}}
MPGB bl wl qb 0   nfet W={{wpg}} L={{lch}}
.control
dc VIN 0 {v} 0.005
wrdata {name}_hold.txt v(qa) v(qb)
alter VWL dc={v}
dc VIN 0 {v} 0.005
wrdata {name}_read.txt v(qa) v(qb)
.endc
.end
"""

WRITE_TRIP = """* write trip (part 1 sim/write_trip.spice) at {c}, VDD = {v} V
.lib {lib} {c}
{sizes}
VDD vdd 0 {v}
VWL wl  0 {v}
VBL bl  0 {v}
VBLB blb 0 {v}
MPUL q  qb vdd vdd pfet W={{wpu}} L={{lch}}
MPDL q  qb 0   0   nfet W={{wpd}} L={{lch}}
MPGL bl wl q   0   nfet W={{wpg}} L={{lch}}
MPUR qb q  vdd vdd pfet W={{wpu}} L={{lch}}
MPDR qb q  0   0   nfet W={{wpd}} L={{lch}}
MPGR blb wl qb 0   nfet W={{wpg}} L={{lch}}
.nodeset v(q)={v} v(qb)=0
.control
dc VBL {v} 0 -0.005
let diff = v(q) - v(qb)
meas dc wtv find v(bl) when diff=0
set wt = $&wtv
echo "WTV $wt"
.endc
.end
"""


def run(deck):
    r = subprocess.run(["ngspice", "-b", deck], cwd=WORK, capture_output=True, text=True)
    return r.stdout + r.stderr          # (not saved: ngspice echoes model lines in its warnings)


def main():
    os.makedirs(WORK, exist_ok=True)
    if not os.path.exists(LIB):
        subprocess.run([os.path.join(S, "scripts", "corner_lib.sh")], check=True, stdout=subprocess.DEVNULL)
    rows, curves = [], {}
    for c, v in CASES:
        name = f"cell_{c}_{v:g}"
        with open(os.path.join(WORK, name + "_bf.spice"), "w") as fo:
            fo.write(BUTTERFLY.format(c=c, v=v, lib=LIB, sizes=SIZES, name=name))
        with open(os.path.join(WORK, name + "_wt.spice"), "w") as fo:
            fo.write(WRITE_TRIP.format(c=c, v=v, lib=LIB, sizes=SIZES))
        run(name + "_bf.spice")
        m = re.search(r"^WTV\s+([-0-9.eE+]+)", run(name + "_wt.spice"), re.M)
        wtv = float(m.group(1)) if m else float("nan")
        hold = snm(*load(os.path.join(WORK, name + "_hold.txt")))[0]
        rd_curves = load(os.path.join(WORK, name + "_read.txt"))
        read = snm(*rd_curves)[0]
        rows.append((c, v, hold, read, wtv))
        if v == 5.0:
            curves[c] = rd_curves
    lines = [f"{'corner':6} {'VDD':>5}  {'hold SNM':>9}  {'read SNM':>9}  {'write trip V(BL)':>16}"]
    for c, v, hold, read, wtv in rows:
        lines.append(f"{c:6} {v:5.1f}  {hold:8.3f}V  {read:8.3f}V  {wtv:15.3f}V")
    text = "\n".join(lines)
    print(text)
    with open(os.path.join(S, "sim", "cell_corners.txt"), "w") as fo:
        fo.write(text + "\n")

    fig, ax = plt.subplots(figsize=(5.6, 5.6), dpi=120)
    colors = {"TT": "black", "SS": "tab:blue", "FF": "tab:red", "SF": "tab:green", "FS": "tab:purple"}
    for c, (ca, cb) in curves.items():
        m = snm(ca, cb)[0]
        ax.plot(*ca, color=colors[c], lw=1.4, label=f"{c}: read SNM = {m:.3f} V")
        ax.plot(*cb, color=colors[c], lw=1.4, ls="--")
    ax.set_xlabel("V(QB) [V]")
    ax.set_ylabel("V(Q) [V]")
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 5)
    ax.set_aspect("equal")
    ax.grid(alpha=0.3)
    ax.legend(loc="upper right", fontsize=9)
    ax.set_title("6T cell read butterfly at the process corners (5 V)")
    fig.tight_layout()
    fig.savefig(os.path.join(S, "sim", "cell_corners.png"))
    print("saved sim/cell_corners.txt, sim/cell_corners.png")


if __name__ == "__main__":
    main()
