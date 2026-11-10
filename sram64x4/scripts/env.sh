# shellcheck shell=bash
# Part 2 (sram64x4) helper settings. Needs the part 1 helpers (scripts/etri050-env.sh) first.
#   source sram64x4/scripts/env.sh      (sram64x4/scripts/setup-kit-extra.sh adds it to ~/.bashrc)

_sram_ws="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SRAM64="$_sram_ws"
if [ -z "${ETRI050_DK:-}" ]; then
  # shellcheck source=/dev/null
  source "$_sram_ws/../scripts/etri050-env.sh"
fi
export ETRI050_STDCELLS="$ETRI050_DK/digital_ETRI"
export ETRI050_STDCELL_SPICE="$ETRI050_STDCELLS/khu_etri050_stdcells.spice"
export ETRI050_STDCELL_LEF="$ETRI050_STDCELLS/etri050_stdcells.lef"
export ETRI050_STDCELL_LIB="$ETRI050_STDCELLS/khu_etri05_stdcells.lib"
export ETRI050_PADS="$ETRI050_DK/pads_ETRI"
export ETRI050_CORNER="$ETRI050_DK/spice/05cmos_mosfet_corner.lib"

# sram-drc <cell>: Magic DRC of a flattened copy of <cell>
#   (in the hierarchical check the kit's standard cells report "This layer can't abut or partially overlap
#    between subcells" where neighbouring cells overlap at their rails; the kit's drc_core.sh ignores that
#    rule, here the copy is flattened instead, so the shapes are merged first like in the GDS)
sram-drc() {
  local cell="${1:?usage: sram-drc <cell>}"
  [ -f "${cell}.mag" ] || { echo "SRAM-DRC ${cell}: no ${cell}.mag here ($(pwd))"; return 1; }
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" <<END_MAGIC
drc off
load ${cell} -force
select top cell
expand
flatten ${cell}_flat
load ${cell}_flat
select top cell
drc on
drc check
drc catchup
puts "SRAM-DRC ${cell}: [drc list count total] error(s)"
drc why
quit -noprompt
END_MAGIC
}

# sram-run <script.tcl>: run a layout script in Magic without the GUI (in the layout folder);
#   the Magic messages go to <script>.log, only problems are shown
#   (not counted: "Cell ... couldn't be read" when a script starts a new cell, and "writing out-of-date
#    timestamp" when the part 1 scripts save the same cell several times within a second)
sram-run() {
  local tcl="${1:?usage: sram-run <script.tcl>}" log bad
  [ -f "$tcl" ] || { echo "SRAM-RUN ${tcl}: no such file here ($(pwd))"; return 1; }
  log="${tcl%.tcl}.log"
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" < "$tcl" > "$log" 2>&1
  bad=$(grep -iE "error|invalid command|can't|couldn't|not found" "$log" | grep -vE "couldn't be read|out-of-date timestamp")
  if [ -n "$bad" ]; then
    echo "SRAM-RUN ${tcl}: problems (log: ${log})"
    echo "$bad" | head -5
    return 1
  fi
  echo "SRAM-RUN ${tcl}: ok   (log: ${log})"
}

# sram-lvs <cell> <reference.spice> [subckt]: same as etri-lvs (the kit's netgen setup), any cell
sram-lvs() { etri-lvs "$@"; }

# sram-gds <cell>: <cell>.mag -> <cell>.gds, flattened first like the kit's generate_chip.sh
#   (contact cuts are then generated on the merged shapes: abutting standard cells share their rail contacts)
sram-gds() {
  local cell="${1:?usage: sram-gds <cell>}"
  [ -f "${cell}.mag" ] || { echo "SRAM-GDS ${cell}: no ${cell}.mag here ($(pwd))"; return 1; }
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" <<END_MAGIC
load ${cell} -force
select top cell
expand
flatten ${cell}_flat
load ${cell}_flat
cif ostyle lambda=0.30(ETRI)
gds write ${cell}
quit -noprompt
END_MAGIC
  ls -l "${cell}.gds"
}
