#!/bin/bash
# ──────────────────────────────────────────────────
# up.sh — Start the Cobbleverse server
# ──────────────────────────────────────────────────
# itzg/minecraft-server always re-runs its init
# on start (verifying modpack + mods). This is
# fast (~30s) because files are cached in ./data.
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶  Starting Cobbleverse server..."
docker compose up -d

echo ""
echo "   ./scripts/logs.sh    → watch progress"
echo "   ./scripts/status.sh  → check health"
echo ""
echo "   First launch: ~5-10 min (downloads ~1 GB)"
echo "   Subsequent:   ~30-60s (cached verification)"
echo ""
echo "   After 'Done!' on first launch, run:"
echo "   ./scripts/apply-extras.sh"
