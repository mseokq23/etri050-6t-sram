#!/usr/bin/env python3
"""Static noise margin from the butterfly curve written by sim/butterfly.spice.

  python3 scripts/snm.py sim/butterfly_hold.txt sim/butterfly_read.txt -o sim/butterfly.png

Each file has 4 columns: x, v(qa), x, v(qb) (half cell A: QB -> Q, half cell B: Q -> QB).
The SNM of a lobe is the side of the largest square between the two curves; the cell's SNM
is the smaller of the two lobes.
"""
import argparse

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def load(path):
    d = np.loadtxt(path)
    x, qa, qb = d[:, 0], d[:, 1], d[:, 3]
    curve_a = (x, qa)      # (QB, Q): Q = fA(QB)
    curve_b = (qb, x)      # (QB, Q): QB = fB(Q)
    return curve_a, curve_b


def snm(curve_a, curve_b, n=2001):
    """Return (snm, [(lobe_snm, x0, y0, side), ...]) for the two lobes."""
    xa, ya = curve_a
    xb, yb = curve_b
    # along lines y - x = c, the position s = x + y of each curve (both monotonic in c)
    ca, sa = ya - xa, ya + xa
    cb, sb = yb - xb, yb + xb
    ia, ib = np.argsort(ca), np.argsort(cb)
    lo, hi = max(ca.min(), cb.min()), min(ca.max(), cb.max())
    c = np.linspace(lo, hi, n)
    s1 = np.interp(c, ca[ia], sa[ia])
    s2 = np.interp(c, cb[ib], sb[ib])
    lobes = []
    for sign, mask in ((+1, c > 0), (-1, c < 0)):
        d = sign * (s1 - s2)
        d = np.where(mask, d, -np.inf)
        k = int(np.argmax(d))
        side = max(d[k], 0.0) / 2.0
        # square corners: (x, y) on curve a and curve b along y - x = c[k]
        xa_k, xb_k = (s1[k] - c[k]) / 2, (s2[k] - c[k]) / 2
        x0 = min(xa_k, xb_k)
        y0 = x0 + c[k]
        lobes.append((side, x0, y0, side))
    return min(l[0] for l in lobes), lobes


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+", help="butterfly_*.txt from sim/butterfly.spice")
    ap.add_argument("-o", "--out", default="butterfly.png")
    ap.add_argument("--title", default="6T SRAM butterfly")
    a = ap.parse_args()

    fig, ax = plt.subplots(figsize=(5.6, 5.6), dpi=120)
    colors = ["tab:blue", "tab:red", "tab:green", "tab:purple"]
    for i, f in enumerate(a.files):
        ca, cb = load(f)
        m, lobes = snm(ca, cb)
        name = f.split("/")[-1].replace("butterfly_", "").replace(".txt", "")
        col = colors[i % len(colors)]
        ax.plot(*ca, color=col, lw=1.6, label=f"{name}: SNM = {m:.3f} V")
        ax.plot(*cb, color=col, lw=1.6, ls="--")
        for side, x0, y0, _ in lobes:
            # the two touching points are opposite corners; (x0, y0) is the lower-left one
            ax.add_patch(plt.Rectangle((x0, y0), side, side, fill=False, ec=col, lw=1.0, ls=":"))
        print(f"{name:6s} SNM = {m:.3f} V   (lobes {lobes[0][0]:.3f} / {lobes[1][0]:.3f} V)")
    ax.set_xlabel("V(QB) [V]")
    ax.set_ylabel("V(Q) [V]")
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 5)
    ax.set_aspect("equal")
    ax.grid(alpha=0.3)
    ax.legend(loc="upper right", fontsize=9)
    ax.set_title(a.title)
    fig.tight_layout()
    fig.savefig(a.out)
    print(f"saved {a.out}")


if __name__ == "__main__":
    main()
