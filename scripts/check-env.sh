#!/usr/bin/env bash
# Quick check of the tools and the ETRI kit: bash scripts/check-env.sh
set -u
WS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$WS/scripts/etri050-env.sh"
TMP=$(mktemp -d)
n_ok=0; n_ng=0
ok() { printf '  OK   %s\n' "$1"; n_ok=$((n_ok + 1)); }
ng() { printf '  FAIL %s\n' "$1"; n_ng=$((n_ng + 1)); }

echo "[1] tools"
for t in xschem ngspice magic netgen klayout python3; do
  command -v "$t" >/dev/null 2>&1 && ok "$t" || ng "$t not found"
done
printf '       magic %s | %s | %s\n' "$(magic --version 2>/dev/null)" \
  "$(ngspice -v 2>/dev/null | grep -o 'ngspice-[0-9]*' | head -1)" "$(klayout -v 2>/dev/null)"

echo "[2] ETRI kit"
for f in "$ETRI050_MODEL" "$ETRI050_MAGICRC" "$ETRI050_NETGEN_SETUP" "$ETRI050_DRC_DECK" "$ETRI050_LYP"; do
  [ -f "$f" ] && ok "${f#"$ETRI050_DK"/}" || ng "missing $f (run: bash scripts/setup-etri050.sh)"
done
[ -e "$HOME/ETRI050_DesignKit/tech" ] && ok "~/ETRI050_DesignKit link" || ng "~/ETRI050_DesignKit link missing"

echo "[3] ngspice + kit model"
cat > "$TMP/vt.spice" <<EOF
.include $ETRI050_MODEL
VG g 0 0
VD d 0 0.1
M1 d g 0 0 nfet W=1.8u L=0.6u
.control
dc VG 0 5 0.01
let id = -i(VD)
meas dc vt find v(g) when id=0.3u
echo "VT_RESULT \$&vt"
.endc
.end
EOF
vt=$(cd "$TMP" && ngspice -b vt.spice 2>/dev/null | sed -n 's/^VT_RESULT *//p')
[ -n "$vt" ] && ok "NMOS 1.8/0.6 Vt = $vt V" || ng "ngspice run"

echo "[4] Magic + ETRI tech"
( cd "$TMP" && magic -dnull -noconsole -rcfile "$ETRI050_MAGICRC" >/dev/null 2>&1 <<'EOF'
snap lambda
load t
box 0 0 18 6
paint ndiffusion
box 8 -2 10 8
paint polysilicon
box 0 0 6 6
paint ndcontact
box 12 0 18 6
paint ndcontact
save t
quit -noprompt
EOF
)
drc=$(cd "$TMP" && etri-drc t 2>/dev/null | sed -n 's/^ETRI-DRC t: \([0-9]*\).*/\1/p')
[ "$drc" = "0" ] && ok "Magic DRC of a test NMOS: 0 errors" || ng "Magic DRC (${drc:-no result})"

echo
echo "check-env: $n_ok OK, $n_ng FAIL"
rm -rf "$TMP"
[ "$n_ng" -eq 0 ]
