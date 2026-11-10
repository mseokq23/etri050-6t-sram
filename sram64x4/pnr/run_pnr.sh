#!/usr/bin/env bash
# place and route of the control block. OpenROAD reads a copy of the kit LEF with three changes:
#   core site height = the real cell height (36 um), metal2 / metal3 spacing 1.05 um (the LEF value is
#   smaller than the ETRI DRC rule), metal2 wire width 1.2 um (wire edges stay on the 0.15 um grid)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p work
sed -E -e '/^SITE[[:space:]]+core/,/^END[[:space:]]+core/ s/SIZE[[:space:]]+[0-9.]+ BY [0-9.]+/SIZE 3.000 BY 36.000/' \
       -e '/^LAYER metal[23]$/,/^END metal[23]/ s/^([[:space:]]*SPACING)[[:space:]]+[0-9.]+ ;/\1 1.05 ;/' \
       -e '/^LAYER metal2$/,/^END metal2/ s/^([[:space:]]*WIDTH)[[:space:]]+[0-9.]+ ;/\1 1.2 ;/' \
       "$ETRI050_STDCELL_LEF" > work/etri050_stdcells.lef
openroad -no_init -exit ctrl.tcl 2>&1 | tee work/pnr.log | grep -E "^\[(ERROR|WARNING) |die origin|Total wire|violations|Placement Analysis" || true
