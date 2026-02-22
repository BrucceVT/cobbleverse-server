#!/bin/bash
# ──────────────────────────────────────────────────
# reset-world.sh — Safely wipes the persistent 
#                  Docker volume 'cobbleverse_data' 
#                  to generate a brand new world.
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

VOLUME_NAME="cobbleverse-server_cobbleverse_data"

echo "⚠️  WARNING: You are about to DELETE the entire server world and player data!"
echo "   This action is IRREVERSIBLE."
echo "   (Make sure you have used ./scripts/backup.sh if you want to keep a copy)"
echo ""
read -p "Are you absolutely sure you want to completely WIPE the world? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Reset cancelled. Your world is safe."
    exit 1
fi

echo "────────────────────────────────────────"
echo "🛑 Stopping the server first..."
docker compose down

echo "🗑️  Deleting persistent volume: $VOLUME_NAME..."
# We try to remove the specific volume. 
# Docker compose automatically prefixes volumes with the project directory name.
if docker volume rm "$VOLUME_NAME" >/dev/null 2>&1 || docker volume rm "cobbleverse_data" >/dev/null 2>&1; then
    echo "✅ Persistent data completely wiped."
else
    echo "⚠️  Could not find or delete volume '$VOLUME_NAME'."
    echo "   (Maybe it was already empty or you are using a different project name?)"
    echo "   You can manually check your volumes with: docker volume ls"
fi

echo "────────────────────────────────────────"
echo "✅ Finished. The next time you run: ./scripts/up.sh"
echo "   The server will generate a completely fresh world."
