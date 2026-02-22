#!/bin/bash
# ──────────────────────────────────────────────────
# apply-xaero-config.sh — Ensure Xaero's Minimap
# and World Map track all players.
# ──────────────────────────────────────────────────
# Handles both scenarios:
#   1. Pre-creates config before mod generates it
#   2. Patches existing config if mod already ran
#
# Idempotent — safe to run multiple times.
# ──────────────────────────────────────────────────
set -euo pipefail
DATA="/data"
XAERO_LIB_DIR="${DATA}/config/xaero/lib"
PROPERTY="everyone_tracks_everyone"
VALUE="true"
LINE="${PROPERTY}:${VALUE}"

# ── Create directory if missing ──────────────────
mkdir -p "${XAERO_LIB_DIR}"

# ── Find existing Xaero lib config files ─────────
# The mod generates files like xaerolib-common.txt
# or similar names inside config/xaero/lib/
FOUND=0
for CFG in "${XAERO_LIB_DIR}"/*.txt; do
  [ -f "${CFG}" ] || continue
  FOUND=1

  if grep -q "${PROPERTY}" "${CFG}"; then
    # Property exists → force it to true
    sed -i "s/${PROPERTY}:false/${PROPERTY}:${VALUE}/" "${CFG}"
    echo "🗺️  Patched $(basename "${CFG}") → ${LINE}"
  else
    # Property missing → append it
    echo "${LINE}" >> "${CFG}"
    echo "🗺️  Appended ${LINE} to $(basename "${CFG}")"
  fi
done

# ── No config files yet → pre-create default ─────
if [ "${FOUND}" -eq 0 ]; then
  DEFAULT_FILE="${XAERO_LIB_DIR}/xaerolib-common.txt"
  echo "${LINE}" > "${DEFAULT_FILE}"
  echo "🗺️  Pre-created ${DEFAULT_FILE} with ${LINE}"
  echo "   Xaero will merge its defaults on first boot."
fi

# ── Also patch legacy files if they exist ────────
LEGACY_FILES=("xaerominimap-common.txt" "xaeroworldmap-common.txt")
LEGACY_PROP="everyoneTracksEveryone"
for LFILE in "${LEGACY_FILES[@]}"; do
  TARGET="${DATA}/config/${LFILE}"
  [ -f "${TARGET}" ] || continue
  if grep -q "${LEGACY_PROP}" "${TARGET}"; then
    sed -i "s/${LEGACY_PROP}:false/${LEGACY_PROP}:true/" "${TARGET}"
    echo "🗺️  Patched legacy ${LFILE} → ${LEGACY_PROP}:true"
  fi
done
