#!/usr/bin/env bash
# Part 2 (sram64x4) needs two more folders of the design kit than part 1:
#   digital_ETRI : standard cells (control block)          pads_ETRI : pad cells and the 28-pin pad frame
# They are added to the same sparse checkout (.pdk/ETRI050_DesignKit, git-ignored, never committed),
# and the part 2 helpers (sram64x4/scripts/env.sh) are loaded in every new terminal.
#   bash sram64x4/scripts/setup-kit-extra.sh       (after scripts/setup-etri050.sh)
set -euo pipefail
WS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KIT_DIR="${ETRI050_KIT_DIR:-$WS/.pdk/ETRI050_DesignKit}"
[ -d "$KIT_DIR/.git" ] || { echo "run scripts/setup-etri050.sh first"; exit 1; }

DIRS=(tech spice scripts digital_ETRI pads_ETRI)
echo "[sram64x4] kit folders: ${DIRS[*]}"
git -C "$KIT_DIR" sparse-checkout set "${DIRS[@]}"

ENVF="$WS/sram64x4/scripts/env.sh"
LINE="if [ -f \"$ENVF\" ]; then source \"$ENVF\"; fi"
grep -qF "$LINE" "$HOME/.bashrc" 2>/dev/null || echo "$LINE" >> "$HOME/.bashrc"

echo "[sram64x4] standard cells: $(ls "$KIT_DIR/digital_ETRI"/*.mag | wc -l) .mag, pad frame: $(ls "$KIT_DIR/pads_ETRI"/MPW_PAD_28Pin_IO.mag)"
echo "[sram64x4] done. open a new terminal (sram-drc, sram-gds, \$ETRI050_PADS ... are then defined)"
