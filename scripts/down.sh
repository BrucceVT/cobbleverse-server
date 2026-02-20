#!/bin/bash
# ──────────────────────────────────────────────────
# down.sh — Stop the Cobbleverse server gracefully
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

echo "⏹  Stopping Cobbleverse server..."
docker compose stop
echo "✅ Server stopped."
echo "   World data persists in ./data/"
echo "   Run ./scripts/up.sh to restart."
