#!/bin/bash
# ──────────────────────────────────────────────────
# init-extras.sh — itzg init.d entry point
# Runs apply-extras.sh (which calls apply-xaero-config.sh)
# inside the container on every startup.
# ──────────────────────────────────────────────────
# Mounted at /itzg/init.d/init-extras.sh
# Scripts are at /scripts/ (mounted volume)
# ──────────────────────────────────────────────────

echo "[init-extras] Applying extras, datapacks and Xaero config..."

# Create symlink so scripts can find project root via cd ..
# apply-extras.sh does: cd "$(dirname "$0")/.."
# From /scripts/, cd .. = /, and ./data = /data, ./extras = /extras
# So we just need /data and /extras to exist at / (they do via volumes)

if [ -x /scripts/apply-extras.sh ]; then
  bash /scripts/apply-extras.sh
  
  echo "[init-extras] Launching auto-setup-regions in background..."
  bash /scripts/auto-setup-regions.sh &
else
  echo "[init-extras] ⚠️  /scripts/apply-extras.sh not found"
fi
