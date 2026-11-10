#!/usr/bin/env python3
"""Internal timing of a schematic-level macro run (gen_tb.py --probe):

  python3 ../scripts/timing.py <out.txt> [-T 50] [--vdd 5]
  per cycle (times from the CLK rising edge, 50 % crossings):
    WL on, SAE (read cycles), SAE - WL, |DL[0] - DLB[0]| when SAE fires (bit 0),
    and after the CLK falling edge: WL off -> PRE_N low (precharge must start after the word line is off)
"""
import argparse, bisect

ap = argparse.ArgumentParser()
ap.add_argument("file")
ap.add_argument("-T", type=float, default=50.0)
ap.add_argument("--vdd", type=float, default=5.0)
args = ap.parse_args()
rows = [list(map(float, l.split())) for l in open(args.file) if l.strip() and l.split()[0][0] in "0123456789-"]
ts = [r[0] for r in rows]
T, V = args.T * 1e-9, args.vdd
CLK, WE, WL0, SAE, PRE, DL, DLB = 1, 2, 7, 23, 24, 25, 26

def cross(col, t0, t1, rising):
    j0, j1 = bisect.bisect_left(ts, t0), bisect.bisect_left(ts, t1)
    for j in range(j0, min(j1, len(rows) - 1)):
        a, b = rows[j][col] - V / 2, rows[j + 1][col] - V / 2
        if (a < 0 <= b) if rising else (a >= 0 > b):
            return rows[j][0] + (rows[j + 1][0] - rows[j][0]) * (-a) / (b - a), j
    return None, None

ncyc = int((ts[-1] - T / 2) // T)
wl_on, sae_on, sae_wl, split, gap = [], [], [], [], []
for i in range(ncyc):
    tr, tf = T / 2 + i * T, (i + 1) * T
    t_wl = min((t for t in (cross(WL0 + r, tr, tf, True)[0] for r in range(16)) if t), default=None)
    if t_wl is None:
        continue
    wl_on.append(t_wl - tr)
    t_sae, j = cross(SAE, tr, tf, True)
    if t_sae:
        sae_on.append(t_sae - tr)
        sae_wl.append(t_sae - t_wl)
        split.append(abs(rows[j][DL] - rows[j][DLB]))
    t_wloff = max((t for t in (cross(WL0 + r, tf, tf + T / 2, False)[0] for r in range(16)) if t), default=None)
    t_pre, _ = cross(PRE, tf, tf + T / 2, False)
    if t_wloff and t_pre:
        gap.append(t_pre - t_wloff)

ns = lambda v: f"{min(v) * 1e9:.2f} .. {max(v) * 1e9:.2f} ns" if v else "-"
print(f"CLK rise -> WL on        : {ns(wl_on)}")
print(f"CLK rise -> SAE (read)   : {ns(sae_on)}")
print(f"WL on -> SAE             : {ns(sae_wl)}")
print(f"|DL - DLB| at SAE (bit 0): {min(split):.2f} .. {max(split):.2f} V" if split else "|DL - DLB| at SAE: -")
print(f"WL off -> PRE_N low      : {ns(gap)}")
