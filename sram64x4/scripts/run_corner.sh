#!/usr/bin/env bash
# run a deck at one process corner (and optionally another supply):
#   ../scripts/run_corner.sh <deck.spice> <TT|SS|FF|SF|FS> [vdd]
# the deck's ".lib ../work/corner.lib TT" line gets the corner, "VDD vdd 0 5" gets the supply
set -euo pipefail
deck="$1"; corner="$2"; vdd="${3:-}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$here/work/corner.lib" ] || "$here/scripts/corner_lib.sh" >/dev/null
tmp="${deck%.spice}_${corner}${vdd:+_$vdd}.spice"
sed -E -e "s#^\.lib ([^ ]*corner\.lib) [A-Z]+#.lib \1 ${corner}#I" "$deck" > "$tmp"
if [ -n "$vdd" ]; then sed -i -E "s/^(VDD vdd 0) [0-9.]+/\1 ${vdd}/I" "$tmp"; fi
ngspice -b "$tmp" 2>&1 | grep -v -E "Reference value|^Warning: Model issue|^ *\.model|unrecognized parameter|^$"
