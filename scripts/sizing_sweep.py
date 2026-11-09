#!/usr/bin/env python3
"""6T cell sizing sweep: read SNM / hold SNM / write trip voltage vs. transistor widths.

  python3 scripts/sizing_sweep.py            (writes sim/sizing_sweep.png and prints a table)

It reuses sim/butterfly.spice and sim/write_trip.spice and only replaces their .param line.
"""
import os
import re
import subprocess
import sys
import tempfile

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
SIM = os.path.join(HERE, "..", "sim")
sys.path.insert(0, HERE)
from snm import load, snm  # noqa: E402

L = 0.6


def run(deck, wpu, wpd, wpg):
    src = open(os.path.join(SIM, deck)).read()
    src = re.sub(r"^\.param .*$", f".param wpu={wpu}u wpd={wpd}u wpg={wpg}u lch={L}u", src, flags=re.M)
    with tempfile.TemporaryDirectory(dir=SIM) as tmp:
        path = os.path.join(tmp, deck)
        open(path, "w").write(src.replace("../.pdk", "../../.pdk"))
        out = subprocess.run(["ngspice", "-b", deck], cwd=tmp, capture_output=True, text=True).stdout
        files = {f: os.path.join(tmp, f) for f in os.listdir(tmp)}
        res = {}
        if "butterfly_hold.txt" in files:
            res["hold"] = snm(*load(files["butterfly_hold.txt"]))[0]
            res["read"] = snm(*load(files["butterfly_read.txt"]))[0]
        m = re.search(r"write trip voltage\s*=\s*([-0-9.eE+]+)", out)
        if m:
            res["wtv"] = float(m.group(1))
        return res


def cell(wpu, wpd, wpg):
    r = run("butterfly.spice", wpu, wpd, wpg)
    r.update(run("write_trip.spice", wpu, wpd, wpg))
    return r


def main():
    pd_list = [1.8, 2.4, 3.0, 3.6, 4.2, 4.8]
    pu_list = [1.8, 2.4, 3.0, 3.6]
    print("PD sweep (PU = 1.8u, PG = 1.8u)")
    print(" PD[um]  beta  holdSNM  readSNM  WTV")
    rows_pd = []
    for wpd in pd_list:
        r = cell(1.8, wpd, 1.8)
        rows_pd.append(r)
        print(f"  {wpd:4.1f}  {wpd / 1.8:4.2f}   {r['hold']:.3f}    {r['read']:.3f}   {r['wtv']:.3f}")
    print("PU sweep (PD = 3.6u, PG = 1.8u)")
    print(" PU[um]  holdSNM  readSNM  WTV")
    rows_pu = []
    for wpu in pu_list:
        r = cell(wpu, 3.6, 1.8)
        rows_pu.append(r)
        print(f"  {wpu:4.1f}   {r['hold']:.3f}    {r['read']:.3f}   {r['wtv']:.3f}")

    fig, axs = plt.subplots(1, 2, figsize=(9.6, 4.0), dpi=120)
    ax = axs[0]
    ax.plot(pd_list, [r["read"] for r in rows_pd], "o-", label="read SNM")
    ax.plot(pd_list, [r["hold"] for r in rows_pd], "s-", label="hold SNM")
    ax.plot(pd_list, [r["wtv"] for r in rows_pd], "^-", label="write trip V(BL)")
    ax.set_xlabel("PD width [um]  (PU = PG = 1.8 um, L = 0.6 um)")
    ax.set_ylabel("[V]")
    ax.set_title("pull-down (PD) sweep")
    ax.grid(alpha=0.3)
    ax.legend(fontsize=8)
    ax = axs[1]
    ax.plot(pu_list, [r["read"] for r in rows_pu], "o-", label="read SNM")
    ax.plot(pu_list, [r["wtv"] for r in rows_pu], "^-", label="write trip V(BL)")
    ax.set_xlabel("PU width [um]  (PD = 3.6 um, PG = 1.8 um)")
    ax.set_title("pull-up (PU) sweep")
    ax.grid(alpha=0.3)
    ax.legend(fontsize=8)
    fig.tight_layout()
    out = os.path.join(SIM, "sizing_sweep.png")
    fig.savefig(out)
    print(f"saved {os.path.relpath(out)}")


if __name__ == "__main__":
    main()
