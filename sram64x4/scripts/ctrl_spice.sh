#!/usr/bin/env bash
# control block netlist for ngspice: rtl/sram64x4_ctrl.v -> sim/sram64x4_ctrl.spice
#   vlog2Spice -i puts the kit's standard-cell netlist into the same file,
#   A[0] -> A_0 because ngspice reads [ ] in .control as a vector index
#   bash ../scripts/ctrl_spice.sh      (from sram64x4/sim)
set -euo pipefail
S="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
vlog2Spice -i -l "$ETRI050_STDCELL_SPICE" -o "$S/sim/sram64x4_ctrl.spice" "$S/rtl/sram64x4_ctrl.v" > /dev/null
sed -i -E 's/\[([0-9]+)\]/_\1/g' "$S/sim/sram64x4_ctrl.spice"
echo "sim/sram64x4_ctrl.spice: $(grep -c '^X' "$S/sim/sram64x4_ctrl.spice") cells, $(grep -c '^\.subckt' "$S/sim/sram64x4_ctrl.spice") subcircuits"
