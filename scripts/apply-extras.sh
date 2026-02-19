#!/bin/bash
# ──────────────────────────────────────────────────
# apply-extras.sh — Apply configs & datapacks from
#                   extras/ into the server's data/
# ──────────────────────────────────────────────────
# Run AFTER the server has started at least once
# (so that ./data/world/ exists).
#
# Safe to re-run: uses cp -r (overwrites existing).
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

EXTRAS="./extras"
DATA="./data"

# ── Validate ─────────────────────────────────────
if [ ! -d "${DATA}" ]; then
  echo "❌ ${DATA}/ not found. Start the server at least once first."
  exit 1
fi

APPLIED=0

# ── 1. Configs ───────────────────────────────────
if [ -d "${EXTRAS}/config" ]; then
  echo "📁 Applying configs → ${DATA}/config/"
  mkdir -p "${DATA}/config"
  cp -r "${EXTRAS}/config/." "${DATA}/config/"
  APPLIED=$((APPLIED + 1))
else
  echo "⚠️  No config/ found in extras — skipping."
fi

# ── 2. Datapacks ─────────────────────────────────
if [ -d "${EXTRAS}/datapack" ]; then
  WORLD_DIR="${DATA}/world"
  if [ ! -d "${WORLD_DIR}" ]; then
    echo "⚠️  ${WORLD_DIR}/ not found yet."
    echo "   Start the server, let the world generate, then re-run this script."
    echo "   (Or create it manually: mkdir -p ${WORLD_DIR}/datapacks)"
  else
    DATAPACKS_DIR="${WORLD_DIR}/datapacks"
    mkdir -p "${DATAPACKS_DIR}"
    echo "📁 Applying datapacks → ${DATAPACKS_DIR}/"
    cp -r "${EXTRAS}/datapack/." "${DATAPACKS_DIR}/"
    APPLIED=$((APPLIED + 1))
  fi
else
  echo "⚠️  No datapack/ found in extras — skipping."
fi

# ── 3. Summary ───────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
if [ "${APPLIED}" -gt 0 ]; then
  echo "✅ Applied ${APPLIED} extra(s) to ${DATA}/."
  echo ""
  echo "   Restart the server to load changes:"
  echo "   ./scripts/down.sh && ./scripts/up.sh"
else
  echo "⚠️  Nothing was applied."
fi
echo "═══════════════════════════════════════"

# ── Info: resourcepacks & shaderpacks ────────────
if [ -d "${EXTRAS}/resourcepacks" ] || [ -d "${EXTRAS}/shaderpacks" ]; then
  echo ""
  echo "ℹ️  resourcepacks/ and shaderpacks/ are in extras/"
  echo "   These are CLIENT-SIDE files."
  echo "   Distribute them to players separately."
  echo "   They are NOT applied to the server automatically."
fi
