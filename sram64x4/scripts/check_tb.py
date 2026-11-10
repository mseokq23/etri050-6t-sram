#!/usr/bin/env python3
"""Check a macro testbench result (gen_tb.py): every read must return the written data.

  python3 ../scripts/check_tb.py <out.txt> [-T 50] [--set all|rowcol] [--vdd 5]
  also prints the largest CLK-fall -> DOUT delay over the read cycles
"""
import argparse, bisect

ap = argparse.ArgumentParser()
ap.add_argument("file")
ap.add_argument("-T", type=float, default=50.0)
ap.add_argument("--set", default="all", choices=["all", "rowcol"])
ap.add_argument("--vdd", type=float, default=5.0)
ap.add_argument("-q", action="store_true", help="summary lines only")
args = ap.parse_args()

addrs = list(range(64)) if args.set == "all" else [r + 16 * (r % 4) for r in range(16)]
rows = [list(map(float, l.split())) for l in open(args.file) if l.strip() and l.split()[0][0] in "0123456789-"]
ts = [r[0] for r in rows]
def at(t):
    return rows[min(bisect.bisect_left(ts, t), len(rows) - 1)]

T, N, V = args.T * 1e-9, len(addrs), args.vdd
data = lambda a: (5 * a + 3) & 0xF
bad, worst = 0, 0.0
for k, a in enumerate(addrs):
    i = N + k                                   # read cycle: CLK rises at T/2 + iT, falls at (i+1)T
    r = at(T / 2 + (i + 1) * T - 1e-9)          # 1 ns before the next rising edge
    word = sum(1 << b for b in range(4) if r[3 + b] > V / 2)
    ok = word == data(a)
    bad += not ok
    if not args.q and (k < 4 or not ok):
        print(f"addr {a:2d}: wrote {data(a):04b} read {word:04b} {'OK' if ok else 'FAIL'}")
    # DOUT delay: last V/2 crossing of any DOUT bit after the falling edge at (i+1)T
    tf = (i + 1) * T
    j0, j1 = bisect.bisect_left(ts, tf), bisect.bisect_left(ts, tf + T / 2)
    for b in range(4):
        for j in range(j0, min(j1, len(rows) - 1)):
            y0, y1 = rows[j][3 + b] - V / 2, rows[j + 1][3 + b] - V / 2
            if y0 * y1 < 0:
                worst = max(worst, rows[j][0] + (rows[j + 1][0] - rows[j][0]) * (-y0) / (y1 - y0) - tf)
print(f"{N} words written and read back: {N - bad} OK, {bad} FAIL")
print(f"CLK fall -> DOUT (slowest bit): {worst * 1e9:.2f} ns")
