#!/usr/bin/env bash
# post-layout check of the macro: extraction with parasitic C (etri-pex), then the 16-word test
# (gen_tb.py --set rowcol) on the extracted netlist and on the schematic netlist, side by side
#   cd sram64x4/sim && bash ../scripts/run_pex.sh        (about 7 minutes, the two runs go in parallel)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../sim"
source ../../scripts/etri050-env.sh
( cd ../layout && etri-pex sram64x4 > sram64x4_pex.log 2>&1 && tail -1 sram64x4_pex.log )
python3 ../scripts/pex_for_sim.py ../layout/sram64x4_pex.spice -o sram64x4_pex.spice
[ -f sram64x4_ctrl.spice ] || bash ../scripts/ctrl_spice.sh
python3 ../scripts/gen_macro_spice.py -o sram64x4.spice > /dev/null
python3 ../scripts/gen_tb.py --set rowcol --probe -o sch16.spice > /dev/null
python3 ../scripts/gen_tb.py --set rowcol --probe --netlist sram64x4_pex.spice -o pex16.spice > /dev/null
ngspice -b sch16.spice > /dev/null 2>&1 &
ngspice -b pex16.spice > /dev/null 2>&1
wait
for n in sch16 pex16; do
  echo "== $n ($( [ $n = sch16 ] && echo schematic || echo extracted ) netlist)"
  python3 ../scripts/check_tb.py "${n}_out.txt" --set rowcol -q
  python3 ../scripts/timing.py "${n}_out.txt"
done
