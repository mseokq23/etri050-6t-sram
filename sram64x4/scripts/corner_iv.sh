#!/usr/bin/env bash
# Vt and Idsat of NMOS / PMOS 1.8u/0.6u at the five process corners and with the part 1 model (sim/corner_iv.spice)
#   cd sram64x4/sim && bash ../scripts/corner_iv.sh
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../sim"
[ -f ../work/corner.lib ] || ../scripts/corner_lib.sh > /dev/null
printf "%-8s %8s %8s %13s %13s\n" corner "Vtn[V]" "|Vtp|[V]" "Idsat_n[uA]" "|Idsat_p|[uA]"
row() { awk -v c="$1" '/^CORNER-IV/ { printf "%-8s %8.3f %8.3f %13.0f %13.0f\n", c, $3, $5, $7, $9 }'; }
for c in TT SS FF SF FS; do
  ../scripts/run_corner.sh corner_iv.spice "$c" | row "$c"
done
# the part 1 model file (05cmos_model_240201.lib) in place of the corner file
sed -E 's#^\.lib .*corner\.lib [A-Z]+#.include ../../.pdk/ETRI050_DesignKit/spice/05cmos_model_240201.lib#' corner_iv.spice > corner_iv_nominal.spice
ngspice -b corner_iv_nominal.spice 2>&1 | row "part1"
rm -f corner_iv_nominal.spice
