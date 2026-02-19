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

mkdir -p "${BACKUP_DIR}"

if [ ! -d "./data" ] || [ -z "$(ls -A ./data 2>/dev/null)" ]; then
  echo "❌ No data to backup. Start the server at least once first."
  exit 1
fi

echo "📦 Creating backup: ${FILENAME}"
echo "   This may take a moment..."

# Pause auto-save if server is running (best-effort)
docker compose exec -T mc rcon-cli save-off 2>/dev/null || true
docker compose exec -T mc rcon-cli save-all 2>/dev/null || true
sleep 2

tar -czf "${BACKUP_DIR}/${FILENAME}" ./data

# Resume auto-save
docker compose exec -T mc rcon-cli save-on 2>/dev/null || true

# Prune old backups — keep only the latest $KEEP
cd "${BACKUP_DIR}"
TOTAL=$(ls -1t cobbleverse_backup_*.tar.gz 2>/dev/null | wc -l)
if [ "${TOTAL}" -gt "${KEEP}" ]; then
  DELETE_COUNT=$((TOTAL - KEEP))
  ls -1t cobbleverse_backup_*.tar.gz | tail -n "${DELETE_COUNT}" | xargs rm -f
  echo "🗑  Pruned ${DELETE_COUNT} old backup(s). Keeping last ${KEEP}."
fi

echo "✅ Backup complete: ${BACKUP_DIR}/${FILENAME}"
echo "   Size: $(du -h "${FILENAME}" | cut -f1)"
