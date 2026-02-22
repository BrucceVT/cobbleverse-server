#!/bin/bash
# ──────────────────────────────────────────────────
# auto-setup-regions.sh — Auto-triggers region 
# structure generation via RCON directly inside the 
# container upon first successful startup.
# ──────────────────────────────────────────────────

MARKER_FILE="/data/.regions_generated"

if [ -f "$MARKER_FILE" ]; then
    echo "[auto-setup-regions] Regions completely generated. Skipping."
    exit 0
fi

echo "[auto-setup-regions] Waiting for Minecraft server to finish starting (RCON port)..."

# Wait until RCON is responsive (max ~15 mins)
MAX_WAITS=180
count=0
while ! rcon-cli "list" > /dev/null 2>&1; do
    sleep 5
    count=$((count+1))
    if [ "$count" -ge "$MAX_WAITS" ]; then
        echo "[auto-setup-regions] ❌ Timed out waiting for server to start. Aborting."
        exit 1
    fi
done

echo "[auto-setup-regions] Server is UP! Starting region generation (Kanto -> Johto -> Hoenn -> Sinnoh)..."
echo "⚠️ This will cause massive temporary lag as chunks are loaded and structures built."

REGIONS=("kanto" "johto" "hoenn" "sinnoh")

for REGION in "${REGIONS[@]}"; do
  echo "▶️ Generating: ${REGION^}..."
  rcon-cli "function setup:${REGION}"
  
  echo "⏳ Waiting 15 seconds to let chunks stabilize..."
  sleep 15
done

# Mark as done so it doesn't run again on next restart
touch "$MARKER_FILE"

echo "✅ All regions have been generated successfully! Market created."
