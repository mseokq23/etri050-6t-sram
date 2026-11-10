#!/usr/bin/env python3
"""corner_table.py <corners.txt>: one line per corner from run_macro_corners.sh (ranges -> worst value)"""
import re
import sys

blocks = re.split(r"^== ", open(sys.argv[1]).read(), flags=re.M)[1:]
print(f"{'corner':6} {'VDD':>4} {'words':>8} {'WL[ns]':>7} {'SAE[ns]':>8} {'WL->SAE':>8} {'dV[V]':>6} "
      f"{'DOUT[ns]':>9} {'PRE gap':>8}")
for b in blocks:
    c, v = re.match(r"(\S+)\s+VDD = (\S+) V", b).groups()
    ok = re.search(r"(\d+) OK, (\d+) FAIL", b)

    def rng(label, worst=max):
        m = re.search(re.escape(label) + r"\s*:\s*([-0-9.]+) \.\. ([-0-9.]+)", b)
        return worst(float(m.group(1)), float(m.group(2))) if m else float("nan")
    dout = float(re.search(r"CLK fall -> DOUT \(slowest bit\): ([0-9.]+)", b).group(1))
    print(f"{c:6} {float(v):4.1f} {ok.group(1) + '/' + str(int(ok.group(1)) + int(ok.group(2))):>8} "
          f"{rng('CLK rise -> WL on'):7.2f} {rng('CLK rise -> SAE (read)'):8.2f} {rng('WL on -> SAE', min):8.2f} "
          f"{rng('|DL - DLB| at SAE (bit 0)', min):6.2f} {dout:9.2f} {rng('WL off -> PRE_N low', min):8.2f}")
