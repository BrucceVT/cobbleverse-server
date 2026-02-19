#!/bin/bash
# ──────────────────────────────────────────────────
# status.sh — Show Cobbleverse server status
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

echo "═══════════════════════════════════════"
echo "  Cobbleverse Server Status"
echo "═══════════════════════════════════════"
echo ""

echo "── Container ──────────────────────────"
docker compose ps
echo ""

echo "── Health ─────────────────────────────"
HEALTH=$(docker inspect --format='{{.State.Health.Status}}' cobbleverse 2>/dev/null || echo "not running")
echo "   Health: ${HEALTH}"
echo ""

echo "── Resources ──────────────────────────"
docker stats cobbleverse --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null || echo "   Container not running"
echo ""

echo "── Mods installed ─────────────────────"
if [ -d "./data/mods" ]; then
  MOD_COUNT=$(find ./data/mods -maxdepth 1 -name '*.jar' 2>/dev/null | wc -l)
  echo "   ${MOD_COUNT} mod(s) in ./data/mods/"
else
  echo "   No mods directory yet (server hasn't started)"
fi
echo ""
