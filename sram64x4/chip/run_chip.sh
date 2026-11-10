#!/usr/bin/env bash
# sram64x4 chip: the kit's 28-pin pad frame + the sram64x4 macro as the core -> sram64x4_Top.gds
#   bash sram64x4/chip/run_chip.sh        (the macro first: sram64x4/layout, source sram64x4.tcl)
#
# same steps as the kit's chip_top Makefile (copy_pad_frame, copy_core, extract_pad,
# extract_pin_route, generate_gds); the routes come from make_top.py instead of hand drawing
# everything is made in sram64x4/chip/work (git-ignored)
set -euo pipefail
CHIP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAYOUT="$(cd "$CHIP/../layout" && pwd)"
WORK="$CHIP/work"
DKS="$ETRI050_DK/scripts"
NAME=sram64x4

[ -f "$LAYOUT/$NAME.mag" ] || { echo "no $LAYOUT/$NAME.mag: build the macro first (layout/sram64x4.tcl)"; exit 1; }
rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK"

# the kit's scripts start plain 'magic', which reads ./.magicrc:
# the kit's chip_top .magicrc (tech, standard cells, pads) + the folder of the macro's cells
cp "$DKS/RTL_Project/ETRI050/chip_top/.magicrc" .
echo "addpath $LAYOUT" >> .magicrc

echo "== 1. pad frame (copy_pad_frame, pad cells changed) and core (copy_core)"
python3 "$CHIP/make_top.py" .
cp "$LAYOUT/$NAME.mag" "${NAME}_Core.mag"

echo "== 2. core placement and routes (top.tcl)"
magic -dnull -noconsole < "$CHIP/top.tcl" > top.log 2>&1
grep -iE "error|invalid|can't|not found" top.log || true

echo "== 3. extract_pad, extract_pin_route"
python3 "$DKS/xPad.py" "$NAME"
python3 "$DKS/xPin_Route_Metal.py" "$NAME"
ls -l "${NAME}_Pad.mag" "${NAME}_Pin_Route.mag"

echo "== 4. positions for generate_chip.sh (lower left corners, um)"
pos() { awk '/^microns:/ { gsub(/[(),]/, " "); x = $5; y = $6 } END { print x, y }'; }
read -r PAD_X PAD_Y < <(bash "$DKS/get_pad_pos.sh" "$NAME" 2>&1 | pos)
read -r ROUTE_X ROUTE_Y < <(bash "$DKS/get_pin_route_pos.sh" "$NAME" 2>&1 | tee pin_route_pos.log | pos)
read -r CORE_X CORE_Y < <(bash "$DKS/get_core_pos.sh" "$NAME" 2>&1 | pos)
echo "pad ($PAD_X, $PAD_Y)  pin_route ($ROUTE_X, $ROUTE_Y)  core ($CORE_X, $CORE_Y)"

echo "== 5. generate_gds (generate_chip.sh)"
bash "$DKS/generate_chip.sh" "$NAME" "$PAD_X" "$PAD_Y" "$ROUTE_X" "$ROUTE_Y" "$CORE_X" "$CORE_Y" \
  > generate_chip.log 2>&1
grep -E "^\* Generate|^\* Read" generate_chip.log || true
mv "${NAME}_Top.gds" "${NAME}_Top_kit.gds"
ls -l "${NAME}_Top_kit.gds"

# generate_chip.sh reads the three GDS files back into Magic and writes them out again; on the way
# the via1 / via2 arrays inside the bond pads are lost (the kit's DRC deck then reports MET1.bad1 and
# MET3.bad1 at every bond pad). Same merge again into a new top cell, but the pad GDS is copied
# as it is (gds readonly); core and routes go through Magic as in generate_chip.sh.
echo "== 6. merge again, pad GDS copied as it is"
magic -dnull -noconsole > merge.log 2>&1 <<EOF
drc off
box 0 0 0 0
cif istyle lambda=0.30(ETRI-G)
cif ostyle lambda=0.30(ETRI-G)
gds read ${NAME}_Core_F
gds read ${NAME}_Pin_Route_F
gds readonly true
gds read ${NAME}_Pad
load ${NAME}_chip
box ${PAD_X}um ${PAD_Y}um ${PAD_X}um ${PAD_Y}um
getcell ${NAME}_Pad
box ${ROUTE_X}um ${ROUTE_Y}um ${ROUTE_X}um ${ROUTE_Y}um
getcell ${NAME}_Pin_Route_F
box ${CORE_X}um ${CORE_Y}um ${CORE_X}um ${CORE_Y}um
getcell ${NAME}_Core_F
gds labels no
gds write ${NAME}_Top
quit -noprompt
EOF
ls -l "${NAME}_Top.gds"
