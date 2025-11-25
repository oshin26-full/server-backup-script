#!/bin/bash
# Script test restore

if [ -z "$1" ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    echo "Available backups:"
    ls -l /backup/daily/*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE=$1
TEST_DIR="/tmp/restore-test-$(date +%s)"

echo "Testing restore from: $BACKUP_FILE"
mkdir -p $TEST_DIR

# Extract backup
tar xzf "$BACKUP_FILE" -C "$TEST_DIR"

echo "Backup extracted to: $TEST_DIR"
echo "Contents:"
find "$TEST_DIR" -type f | head -20

echo ""
echo "✅ Restore test completed"
echo "📁 Test directory: $TEST_DIR"
