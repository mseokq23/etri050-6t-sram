#!/usr/bin/env bash
# Downloads the ETRI 0.5 um open-source design kit from its own repository and links it
# for Magic / Xschem / ngspice / Netgen / KLayout. The kit is NOT stored in this repository.
#
#   kit:  https://github.com/GoodKook/ETRI-0.5um-CMOS-MPW-Std-Cell-DK
#   to:   .pdk/ETRI050_DesignKit   (git-ignored)
#
# Only the folders this guide needs are checked out (tech, spice, scripts: about 30 MB).
# Running it again updates the kit.
set -euo pipefail

WS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIT_REPO="${ETRI050_KIT_REPO:-https://github.com/GoodKook/ETRI-0.5um-CMOS-MPW-Std-Cell-DK.git}"
KIT_DIR="${ETRI050_KIT_DIR:-$WS/.pdk/ETRI050_DesignKit}"
DIRS=(tech spice scripts)

if [ ! -d "$KIT_DIR/.git" ]; then
  echo "[etri050] clone $KIT_REPO"
  echo "[etri050]   -> $KIT_DIR (sparse: ${DIRS[*]})"
  mkdir -p "$(dirname "$KIT_DIR")"
  git clone --quiet --depth 1 --filter=blob:none --sparse "$KIT_REPO" "$KIT_DIR"
  git -C "$KIT_DIR" sparse-checkout set "${DIRS[@]}"
else
  echo "[etri050] update $KIT_DIR"
  git -C "$KIT_DIR" sparse-checkout set "${DIRS[@]}"
  git -C "$KIT_DIR" pull --quiet --ff-only || echo "[etri050] pull skipped"
fi

# the kit's magicrc looks for the kit at ~/ETRI050_DesignKit
ln -sfn "$KIT_DIR" "$HOME/ETRI050_DesignKit"

# helper commands (magic-etri, xschem-etri, etri-drc, etri-lvs, ...) in every new terminal
ENVF="$WS/scripts/etri050-env.sh"
LINE="if [ -f \"$ENVF\" ]; then source \"$ENVF\"; fi"
grep -qF "$LINE" "$HOME/.bashrc" 2>/dev/null || echo "$LINE" >> "$HOME/.bashrc"

echo "[etri050] kit    : $KIT_DIR ($(git -C "$KIT_DIR" log -1 --format='%h %cs'))"
echo "[etri050] model  : $KIT_DIR/spice/05cmos_model_240201.lib"
echo "[etri050] magic  : $KIT_DIR/tech/etri050.magicrc"
echo "[etri050] done. open a new terminal and run: bash scripts/check-env.sh"
