#!/usr/bin/env bash
# Copy of the kit's corner model file for this repo's netlists, written to sram64x4/work/ (git-ignored):
#   the kit file names its models nmos4 / pmos4, the netlists here use nfet / pfet (part 1 model file names),
#   and its sections include the file itself by a relative path, which is pointed at the copy
# usage: scripts/corner_lib.sh  ->  sram64x4/work/corner.lib  (then: .lib <path>/corner.lib TT|SS|FF|SF|FS)
set -euo pipefail
WS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$WS/work"
src="${ETRI050_CORNER:-$WS/../.pdk/ETRI050_DesignKit/spice/05cmos_mosfet_corner.lib}"
sed -E -e 's/^(\.MODEL[[:space:]]+)nmos4([[:space:]])/\1nfet\2/I' \
       -e 's/^(\.MODEL[[:space:]]+)pmos4([[:space:]])/\1pfet\2/I' \
       -e "s#'\./05cmos_mosfet_corner\.lib'#'$WS/work/corner.lib'#" \
       "$src" > "$WS/work/corner.lib"
echo "corner models: $WS/work/corner.lib  (sections: $(grep -i '^\.LIB [A-Z]' "$WS/work/corner.lib" | awk '{print $2}' | grep -v "'" | tr '\n' ' '))"
