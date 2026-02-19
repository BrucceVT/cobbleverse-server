#!/bin/bash
# ──────────────────────────────────────────────────
# down.sh — Stop the Cobbleverse server gracefully
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

echo "⏹  Stopping Cobbleverse server..."
docker compose down
echo "✅ Server stopped."
