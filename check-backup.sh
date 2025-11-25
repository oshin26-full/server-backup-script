#!/bin/bash
# Script monitoring backup

LOG_FILE="/var/log/backups/server-backup.log"
BACKUP_DIR="/backup/daily"

echo "=== BACKUP STATUS CHECK ==="
echo "Last backup check: $(date)"

# Cek last backup file
LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.tar.gz 2>/dev/null | head -1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "Latest backup: $(basename $LATEST_BACKUP)"
    echo "Backup size: $(du -h $LATEST_BACKUP | cut -f1)"
    echo "Backup age: $(find $LATEST_BACKUP -mtime -1 -exec echo "FRESH" \; || echo "STALE")"
else
    echo "❌ No backup files found!"
fi

# Cek last log entry
echo ""
echo "=== LAST LOG ENTRIES ==="
tail -5 $LOG_FILE 2>/dev/null || echo "No log file found"
