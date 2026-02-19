#!/bin/bash
# ──────────────────────────────────────────────────
# up.sh — Start the Cobbleverse server
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶  Starting Cobbleverse server..."
docker compose up -d

echo ""
echo "⏳ First launch downloads the modpack (~1 GB) — grab a coffee ☕"
echo ""
echo "   ./scripts/logs.sh    → watch progress"
echo "   ./scripts/status.sh  → check health"
