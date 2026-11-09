# shellcheck shell=bash
# ETRI 0.5 um helper commands for IIC-OSIC-TOOLS.
# scripts/setup-etri050.sh adds "source <repo>/scripts/etri050-env.sh" to ~/.bashrc.
#
#   magic-etri [cell]                       Magic with the ETRI technology
#   xschem-etri [file.sch]                  Xschem with this repo's xschemrc
#   klayout-etri [file.gds]                 KLayout with the ETRI layer colours
#   etri-drc <cell>                         Magic DRC of <cell>.mag in the current folder
#   etri-lvs <cell> <sch.spice> [subckt]    Magic extraction + Netgen LVS
#   etri-pex <cell>                         extraction with parasitic C -> <cell>_pex.spice
#   etri-gds <cell>                         <cell>.mag -> <cell>.gds (ETRI layer numbers)
#   etri-drc-klayout <file.gds>             KLayout DRC with the kit's rule deck

_etri_ws="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ETRI050_WS="$_etri_ws"
export ETRI050_DK="${ETRI050_DK:-$_etri_ws/.pdk/ETRI050_DesignKit}"
export ETRI050_MODEL="${ETRI050_MODEL:-$ETRI050_DK/spice/05cmos_model_240201.lib}"
export ETRI050_MAGICRC="$ETRI050_DK/tech/etri050.magicrc"
export ETRI050_NETGEN_SETUP="$ETRI050_DK/tech/etri050_setup.tcl"
export ETRI050_DRC_DECK="$ETRI050_DK/tech/Klayout_DRC_Script/etri_05um_generated_final.drc"
export ETRI050_LYP="$ETRI050_DK/tech/ETRI050_CMOS.lyp"
export DISPLAY="${DISPLAY:-:1}"

# the image's default KLayout setup is for IHP SG13G2, so ETRI sessions use only ~/.klayout
_etri_klayout() { KLAYOUT_PATH="$HOME/.klayout" klayout "$@"; }

magic-etri()   { magic -rcfile "$ETRI050_MAGICRC" "$@"; }
xschem-etri()  { xschem --rcfile "$_etri_ws/xschemrc" "$@"; }
klayout-etri() { _etri_klayout -l "$ETRI050_LYP" -rm "$_etri_ws/scripts/klayout/etri_view.rb" "$@"; }

etri-drc() {
  local cell="${1:?usage: etri-drc <cell>}"
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" <<EOF
drc off
load ${cell} -force
select top cell
drc on
drc check
drc catchup
puts "ETRI-DRC ${cell}: [drc list count total] error(s)"
drc why
quit -noprompt
EOF
}

etri-gds() {
  local cell="${1:?usage: etri-gds <cell>}"
  # the default CIF/GDS style writes MOSIS layer numbers; ETRI needs lambda=0.30(ETRI)
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" <<EOF
load ${cell} -force
cif ostyle lambda=0.30(ETRI)
gds write ${cell}.gds
quit -noprompt
EOF
  ls -l "${cell}.gds"
}

etri-pex() {
  local cell="${1:?usage: etri-pex <cell>}"
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" <<EOF
load ${cell} -force
extract all
ext2spice lvs
ext2spice hierarchy off
ext2spice subcircuit top on
ext2spice cthresh 0
ext2spice -o ${cell}_pex.spice
quit -noprompt
EOF
  echo "ETRI-PEX ${cell}: ${cell}_pex.spice ($(grep -c '^C' "${cell}_pex.spice") capacitors)"
}

etri-lvs() {
  local usage="usage: etri-lvs <cell> <schematic.spice> [schematic_subckt]"
  local cell="${1:?$usage}" sch="${2:?$usage}" sub="${3:-$1}" out="${1}_lvs.out" verdict
  # extraction writes <cell>.spice next to <cell>.mag, so keep the schematic netlist elsewhere
  magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" >"${cell}_ext.log" 2>&1 <<EOF
load ${cell} -force
extract all
ext2spice lvs
ext2spice
quit -noprompt
EOF
  # (the kit setup file asks for FILL cells that a small design does not have: those notes go to the log)
  netgen -batch lvs "${cell}.spice ${cell}" "${sch} ${sub}" "$ETRI050_NETGEN_SETUP" "$out" >"${cell}_netgen.log" 2>&1
  if grep -qE "do not match|failed pin matching|with port errors" "$out"; then
    verdict="MISMATCH"
  elif grep -qE "Circuits match|Netlists match" "$out"; then
    verdict="MATCH"
    grep -qE "Property errors were found|There were property errors" "$out" && verdict="MATCH but property errors"
  else
    verdict="no result"
  fi
  echo "ETRI-LVS ${cell}: ${verdict}   (details: ${out})"
}

etri-drc-klayout() {
  local gds="${1:?usage: etri-drc-klayout <file.gds> [report.lyrdb]}"
  local rpt="${2:-${gds%.gds}_drc.lyrdb}"
  _etri_klayout -b -r "$ETRI050_DRC_DECK" -rd gdsfile="$gds" -rd resultsfile="$rpt"
  python3 - "$rpt" <<'PY'
import sys, collections, xml.etree.ElementTree as ET
items = ET.parse(sys.argv[1]).getroot().find("items")
cnt = collections.Counter((i.findtext("category") or "?").strip("'") for i in (items if items is not None else []))
print(f"ETRI-DRC-KLAYOUT: {sum(cnt.values())} marker(s)", " ".join(f"{k}:{v}" for k, v in sorted(cnt.items())))
PY
  echo "report: $rpt   (klayout-etri $gds -m $rpt)"
}
