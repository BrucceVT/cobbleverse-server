#!/bin/bash
# ──────────────────────────────────────────────────
# backup.sh — Backup Cobbleverse world data (Container-Side)
# ──────────────────────────────────────────────────
# Creates a timestamped tar.gz of /data into /data/backups/
# Keeps the last N backups (default 5).
# ──────────────────────────────────────────────────
set -euo pipefail

KEEP=${1:-5}
BACKUP_DIR="/data/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="cobbleverse_backup_${TIMESTAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"

echo "📦 Creating backup: ${BACKUP_DIR}/${FILENAME}"
echo "   This may take a moment..."

# Pause auto-save if using integrated RCON
if command -v rcon-cli &> /dev/null; then
  rcon-cli save-off 2>/dev/null || true
  rcon-cli save-all 2>/dev/null || true
  sleep 2
fi

# Tar the /data folder excluding the backups directory itself
tar -czf "${BACKUP_DIR}/${FILENAME}" --exclude='./backups' -C /data .

# Resume auto-save
if command -v rcon-cli &> /dev/null; then
  rcon-cli save-on 2>/dev/null || true
fi

# Prune old backups
cd "${BACKUP_DIR}"
TOTAL=$(ls -1t cobbleverse_backup_*.tar.gz 2>/dev/null | wc -l || echo 0)
if [ "${TOTAL}" -gt "${KEEP}" ]; then
  DELETE_COUNT=$((TOTAL - KEEP))
  ls -1t cobbleverse_backup_*.tar.gz 2>/dev/null | tail -n "${DELETE_COUNT}" | xargs -r rm -f
  echo "🗑  Pruned ${DELETE_COUNT} old backup(s). Keeping last ${KEEP}."
fi

echo "✅ Backup complete: ${BACKUP_DIR}/${FILENAME}"
ls -lh "${BACKUP_DIR}/${FILENAME}" | awk '{print "   Size: "$5}'
