#!/bin/bash
# ──────────────────────────────────────────────────
# auto-setup-regions.sh — Auto-generates regions
# Runs in background, waiting for RCON to be ready
# ──────────────────────────────────────────────────
# Only triggers once per world (/data/regions.generated)

MARKER_FILE="/data/regions.generated"

if [ -f "$MARKER_FILE" ]; then
    echo "[auto-setup-regions] ✅ Regions already generated. Skipping."
    exit 0
fi

echo "[auto-setup-regions] ⏳ Waiting for server RCON to be ready..."

# Wait until rcon-cli works (server fully started)
until rcon-cli "list" > /dev/null 2>&1; do
    sleep 10
done

# Wait extra 60s for server to completely stabilize
echo "[auto-setup-regions] RCON confirmed. Waiting 60s before generating to avoid boot stack..."
sleep 60

echo "[auto-setup-regions] 🌍 Starting region generation (Kanto -> Johto -> Hoenn -> Sinnoh)..."
echo "[auto-setup-regions] ⚠️ HIGH CPU usage expected in the next minute."

REGIONS=("kanto" "johto" "hoenn" "sinnoh")

for REGION in "${REGIONS[@]}"; do
  echo "[auto-setup-regions] ▶️ Triggering: ${REGION^}..."
  rcon-cli "function setup:${REGION}"
  echo "[auto-setup-regions] ⏳ Waiting 15s to stabilize chunks..."
  sleep 15
done

echo "[auto-setup-regions] ✅ Generation complete! Applying marker file."
date > "$MARKER_FILE"
