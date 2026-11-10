#!/usr/bin/env bash
# LVS reference netlists of the sram64x4 macro (in the layout folder)
#   sram64x4_ctrl_ref.spice : control block (rtl/sram64x4_ctrl.v -> scripts/v2spice.py, kit's cell netlist included)
#   sram64x4_ref.spice      : part 1 cell (sim/sram6t_cell.spice) + peripheral circuits (sim/periph.spice)
#                             + control block + macro top (scripts/gen_macro_spice.py --lvs --no-wire)
#   bash lvs_ref.sh      then   sram-lvs sram64x4_ctrl sram64x4_ctrl_ref.spice / sram-lvs sram64x4 sram64x4_ref.spice
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
python3 ../scripts/v2spice.py ../rtl/sram64x4_ctrl.v -l "$ETRI050_STDCELL_SPICE" -o sram64x4_ctrl_ref.spice > /dev/null
python3 ../scripts/gen_macro_spice.py --lvs --no-wire -o ../work/macro_top_lvs.spice > /dev/null
{
  cat ../../sim/sram6t_cell.spice
  echo
  cat ../sim/periph.spice
  echo
  sed '/^\.end$/d' sram64x4_ctrl_ref.spice
  echo
  cat ../work/macro_top_lvs.spice
  echo ".end"
} > sram64x4_ref.spice
grep -c "^\.subckt" sram64x4_ref.spice | xargs echo "sram64x4_ref.spice: subcircuits"
