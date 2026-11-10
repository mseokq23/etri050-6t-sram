#!/usr/bin/env python3
"""drc_diff.py <chip.lyrdb> <pads_alone.lyrdb>

  compares the KLayout DRC markers of the whole chip with those of the pad frame alone
  (same rule, same place = same marker); prints the markers that only the chip has
"""
import collections
import re
import sys
import xml.etree.ElementTree as ET


def markers(path):
    out = collections.Counter()
    items = ET.parse(path).getroot().find("items")
    for it in (items if items is not None else []):
        rule = (it.findtext("category") or "?").strip("'")
        text = " ".join(v.text or "" for v in it.find("values"))
        nums = [float(v) for v in re.findall(r"-?\d+(?:\.\d+)?", text)]
        xs, ys = nums[0::2], nums[1::2]
        out[(rule, round(min(xs), 2), round(min(ys), 2), round(max(xs), 2), round(max(ys), 2))] += 1
    return out


chip, pads = markers(sys.argv[1]), markers(sys.argv[2])
extra = chip - pads
by_rule = collections.Counter(m[0] for m in chip.elements())
print(f"{sys.argv[1]}: {sum(chip.values())} marker(s)",
      " ".join(f"{k}:{v}" for k, v in sorted(by_rule.items())))
print(f"  same as the pads alone ({sys.argv[2]}): {sum((chip & pads).values())}")
extra_rules = collections.Counter(m[0] for m in extra.elements())
print(f"  only in the chip: {sum(extra.values())}",
      " ".join(f"{k}:{v}" for k, v in sorted(extra_rules.items())))
for (rule, x0, y0, x1, y1), n in sorted(extra.items())[:3]:
    print(f"    e.g. {rule}  ({x0}, {y0}) - ({x1}, {y1})")
