#!/usr/bin/env python3
"""Overlay the schematic and post-layout runs of sim/cell_tran*.spice.

  cd sim && ngspice -b cell_tran.spice && ngspice -b cell_tran_pex.spice
  python3 ../scripts/plot_tran.py cell_tran_out.txt cell_tran_pex_out.txt -o cell_tran_cmp.png

wrdata columns: t v(wl)  t v(q)  t v(qb)  t v(bl)  t v(blb)  t v(dout)
"""
import argparse

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

NAMES = ["WL", "Q", "QB", "BL", "BLB", "DOUT"]


def load(path):
    d = np.loadtxt(path)
    t = d[:, 0] * 1e9
    return t, {n: d[:, 2 * i + 1] for i, n in enumerate(NAMES)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sch")
    ap.add_argument("pex")
    ap.add_argument("-o", "--out", default="cell_tran_cmp.png")
    ap.add_argument("--xlim", nargs=2, type=float, default=None)
    a = ap.parse_args()
    ts, s = load(a.sch)
    tp, p = load(a.pex)
    groups = [("WL", "Q", "QB"), ("BL", "BLB"), ("DOUT",)]
    fig, axs = plt.subplots(3, 1, figsize=(9, 7), dpi=110, sharex=True)
    colors = {"WL": "tab:gray", "Q": "tab:blue", "QB": "tab:orange", "BL": "tab:red",
              "BLB": "tab:green", "DOUT": "tab:purple"}
    for ax, g in zip(axs, groups):
        for n in g:
            ax.plot(ts, s[n], color=colors[n], lw=1.4, label=f"{n} (schematic)")
            ax.plot(tp, p[n], color=colors[n], lw=1.0, ls="--", label=f"{n} (layout)")
        ax.set_ylabel("[V]")
        ax.grid(alpha=0.3)
        ax.legend(fontsize=7, ncol=3, loc="upper right")
    axs[-1].set_xlabel("time [ns]")
    if a.xlim:
        axs[-1].set_xlim(*a.xlim)
    axs[0].set_title("write 1 / read / write 0 / read : schematic vs. extracted layout")
    fig.tight_layout()
    fig.savefig(a.out)
    print(f"saved {a.out}")


if __name__ == "__main__":
    main()
