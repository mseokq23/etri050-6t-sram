#!/usr/bin/env bash
# schematic-level macro at the kit's process corners (16 words, T = 50 ns) + supply 4.5 / 5.5 V at SS / FF
#   cd sram64x4/sim && bash ../scripts/run_macro_corners.sh   -> corners.txt + a table (about 35 minutes)
set -uo pipefail
[ -f ../work/corner.lib ] || ../scripts/corner_lib.sh >/dev/null
: > corners.txt
for cv in TT:5 SS:5 FF:5 SF:5 FS:5 SS:4.5 FF:5.5; do
  c=${cv%:*}; v=${cv#*:}
  deck="corner_${c}_${v}.spice"
  python3 ../scripts/gen_tb.py --set rowcol --probe --corner "$c" --vdd "$v" -o "$deck" > /dev/null
  ngspice -b "$deck" > /dev/null 2>&1
  {
    echo "== $c  VDD = $v V"
    python3 ../scripts/check_tb.py "${deck%.spice}_out.txt" --set rowcol --vdd "$v" -q
    python3 ../scripts/timing.py "${deck%.spice}_out.txt" --vdd "$v"
  } >> corners.txt
  echo "$c  VDD = $v V : $(grep -oE '[0-9]+ OK, [0-9]+ FAIL' corners.txt | tail -1)"
done
echo
python3 ../scripts/corner_table.py corners.txt
