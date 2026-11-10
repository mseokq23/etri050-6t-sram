#!/usr/bin/env bash
# checks of the sram64x4 chip, after run_chip.sh (everything in sram64x4/chip/work)
#   bash sram64x4/chip/check_chip.sh
#   1. core DRC with the kit's drc_core.sh
#   2. macro + routes, flattened: Magic DRC, stacked vias (the kit's check_via_stack.py)
#   3. routes LVS: labels on the pad pins must reach the right macro pins (and nothing else)
#   4. KLayout DRC (the kit's deck) of the pads alone, the kit's chip GDS and the final chip GDS
set -uo pipefail
CHIP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAYOUT="$(cd "$CHIP/../layout" && pwd)"
DKS="$ETRI050_DK/scripts"
NAME=sram64x4
cd "$CHIP/work"
# etri-drc-klayout and the kit paths
source "$CHIP/../../scripts/etri050-env.sh"

echo "== 1. core DRC (drc_core.sh: the standard cells' overlap rule ignored, as in the kit)"
bash "$DKS/drc_core.sh" "${NAME}_Core" > core_drc.log 2>&1
grep -E "^Total DRC errors found|^No errors found" core_drc.log | tail -2

echo "== 2. macro + routes flattened: Magic DRC, stacked vias"
magic -dnull -noconsole > chipnet_drc.log 2>&1 <<EOF
drc off
load ${NAME}_chipnet
select top cell
expand
flatten ${NAME}_chipnet_F
load ${NAME}_chipnet_F
save ${NAME}_chipnet_F
select top cell
drc on
drc check
drc catchup
puts "MAGIC-DRC ${NAME}_chipnet_F: [drc list count total] error(s)"
drc why
quit -noprompt
EOF
grep -A20 "^MAGIC-DRC" chipnet_drc.log | grep -v "^$"
python3 "$DKS/check_via_stack.py" "${NAME}_chipnet_F" m2contact m3contact 6 > via_stack.log 2>&1
grep -E "^Checking|^Stacked|stacked" via_stack.log

echo "== 3. routes LVS (pad pin labels -> macro pins)"
[ -f "$LAYOUT/${NAME}_ref.spice" ] || bash "$LAYOUT/lvs_ref.sh"
cat "$LAYOUT/${NAME}_ref.spice" chipnet_top.spice > chipnet_ref.spice
magic -dnull -noconsole > chipnet_ext.log 2>&1 <<EOF
load ${NAME}_chipnet
extract all
ext2spice lvs
ext2spice
quit -noprompt
EOF
netgen -batch lvs "${NAME}_chipnet.spice ${NAME}_chipnet" "chipnet_ref.spice ${NAME}_chipnet" \
  "$ETRI050_NETGEN_SETUP" chipnet_lvs.out > chipnet_netgen.log 2>&1
if grep -qE "do not match|failed pin matching|with port errors" chipnet_lvs.out; then
  echo "ROUTES-LVS: MISMATCH (chipnet_lvs.out)"
elif grep -qE "Circuits match|Netlists match" chipnet_lvs.out; then
  echo "ROUTES-LVS: MATCH (chipnet_lvs.out)"
else
  echo "ROUTES-LVS: no result (chipnet_netgen.log)"
fi

echo "== 4. KLayout DRC: pads alone / kit's chip GDS / final chip GDS"
for g in "${NAME}_Pad" "${NAME}_Top_kit" "${NAME}_Top"; do
  etri-drc-klayout "$g.gds" > "${g}_drc.txt" 2>&1
done
python3 "$CHIP/drc_diff.py" "${NAME}_Top_kit_drc.lyrdb" "${NAME}_Pad_drc.lyrdb"
python3 "$CHIP/drc_diff.py" "${NAME}_Top_drc.lyrdb" "${NAME}_Pad_drc.lyrdb"
klayout -b -r "$CHIP/gds_info.py" -rd gds="${NAME}_Top.gds"
