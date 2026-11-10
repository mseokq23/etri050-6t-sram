#!/usr/bin/env bash
# control block netlist for ngspice: rtl/sram64x4_ctrl.v -> sim/sram64x4_ctrl.spice
#   v2spice.py --inline puts the kit's standard-cell netlist into the same file,
#   --underscore: A[0] -> A_0 because ngspice reads [ ] in .control as a vector index
#   (scripts/v2spice.py instead of qflow's vlog2Spice: see the note in that script)
#   bash ../scripts/ctrl_spice.sh      (from sram64x4/sim)
set -euo pipefail
S="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$S/scripts/v2spice.py" "$S/rtl/sram64x4_ctrl.v" -l "$ETRI050_STDCELL_SPICE" \
  -o "$S/sim/sram64x4_ctrl.spice" --inline --underscore > /dev/null
n_top=$(awk '/^\.subckt sram64x4_ctrl /{f=1} f && /^X/{n++} f && /^\.ends/{f=0} END{print n}' "$S/sim/sram64x4_ctrl.spice")
n_sub=$(grep -c '^\.subckt' "$S/sim/sram64x4_ctrl.spice")
echo "sim/sram64x4_ctrl.spice: sram64x4_ctrl = ${n_top} standard cells, ${n_sub} subcircuits in the file (kit cells + sram64x4_ctrl)"
