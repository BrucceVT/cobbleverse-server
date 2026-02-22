#!/bin/bash
# ──────────────────────────────────────────────────
# backup.sh — Backup Cobbleverse world data
# ──────────────────────────────────────────────────
# Creates a timestamped tar.gz of ./data into ./backups/
# Keeps the last N backups (default 5).
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

KEEP=${1:-5}
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="cobbleverse_backup_${TIMESTAMP}.tar.gz"
VOLUME_NAME="cobbleverse_data"

mkdir -p "${BACKUP_DIR}"

echo "📦 Creating backup: ${FILENAME}"
echo "   This may take a moment..."

# 1. Dynamically find the running Minecraft container id/name (Dokploy changes names)
MC_CONTAINER=$(docker ps -q --filter "ancestor=itzg/minecraft-server" | head -n 1)

if [ -z "${MC_CONTAINER}" ]; then
  echo "❌ Error: Could not find a running Minecraft container (itzg/minecraft-server)."
  echo "   Please start the server first."
  exit 1
fi

# 2. Find the exact volume name attached to /data inside that container
VOLUME_NAME=$(docker inspect "${MC_CONTAINER}" -f '{{ range .Mounts }}{{ if eq .Destination "/data" }}{{ .Name }}{{ end }}{{ end }}')

if [ -z "${VOLUME_NAME}" ]; then
  echo "❌ Error: Could not determine the volume mounted to /data."
  exit 1
fi

# Pause auto-save if server is running (best-effort)
docker exec "${MC_CONTAINER}" rcon-cli save-off 2>/dev/null || true
docker exec "${MC_CONTAINER}" rcon-cli save-all 2>/dev/null || true
sleep 2

# We use an alpine container to mount the exact named volume and tar its contents
docker run --rm \
  -v "${VOLUME_NAME}:/data:ro" \
  -v "$(pwd)/${BACKUP_DIR}:/backup" \
  alpine tar -czf "/backup/${FILENAME}" -C /data .

# Resume auto-save
docker exec "${MC_CONTAINER}" rcon-cli save-on 2>/dev/null || true

# Prune old backups
cd "${BACKUP_DIR}"
TOTAL=$(ls -1t cobbleverse_backup_*.tar.gz 2>/dev/null | wc -l || echo 0)
if [ "${TOTAL}" -gt "${KEEP}" ]; then
  DELETE_COUNT=$((TOTAL - KEEP))
  ls -1t cobbleverse_backup_*.tar.gz | tail -n "${DELETE_COUNT}" | xargs rm -f
  echo "🗑  Pruned ${DELETE_COUNT} old backup(s). Keeping last ${KEEP}."
fi

echo "✅ Backup complete: ${BACKUP_DIR}/${FILENAME}"
echo "   Size: $(du -h "${FILENAME}" | cut -f1)"
