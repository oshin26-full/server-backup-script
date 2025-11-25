#!/bin/bash

# Config
DB_USER="root"
DB_PASSWORD="GANTI_PASSWORD_MYSQL_ANDA"
BACKUP_ROOT="/backup"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$BACKUP_ROOT/full-backup-$DATE"
RETENTION_DAYS=7
LOG_FILE="/var/log/backups/server-backup.log"

# Directory yang di mau di backup
IMPORTANT_DIRS=(
    "/etc"
    "/home"
    "/var/www"
)

# Fungsi log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# Prepare backup server
log "MEMULAI BACKUP SERVER..."

# Cek root
if [ "$EUID" -ne 0 ]; then
    error_exit "Jalankan sebagai root: sudo $0"
fi

# Buat directory
mkdir -p $BACKUP_DIR || error_exit "Gagal buat direktori backup"
cd $BACKUP_DIR
mkdir -p mysql configs

# Backup database MySQL nya
log "1. Backup database MySQL..."

# Test koneksi MySQL nya
if ! mysql -u $DB_USER -p$DB_PASSWORD -e "SELECT 1" >/dev/null 2>&1; then
    log "    MySQL tidak bisa diakses, skip database backup"
else
    DATABASES=$(mysql -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

    for DB in $DATABASES; do
        log "   - Backup: $DB"
        if mysqldump -u $DB_USER -p$DB_PASSWORD --single-transaction $DB > "mysql/${DB}.sql" 2>> $LOG_FILE; then
            SIZE=$(du -h "mysql/${DB}.sql" | cut -f1)
            log "      Sukses ($SIZE)"
        else
            log "      Gagal"
        fi
    done
fi

# Backup file config
log "2. Backup file konfigurasi..."

cp --parents /etc/passwd configs/ 2>/dev/null && log "    /etc/passwd"
cp --parents /etc/group configs/ 2>/dev/null && log "    /etc/group"
cp --parents /etc/fstab configs/ 2>/dev/null && log "    /etc/fstab"
cp --parents /etc/hosts configs/ 2>/dev/null && log "    /etc/hosts"

# Backup Directory Penting
log "3. Backup direktori penting..."

for dir in "${IMPORTANT_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        log "   - Backup: $dir"

        if tar czf "${dir_name}.tar.gz" -C "/" "${dir:1}" 2>> $LOG_FILE; then
            SIZE=$(du -h "${dir_name}.tar.gz" | cut -f1)
            log "      Sukses ($SIZE)"
        else
            log "      Gagal"
        fi
    else
        log "    Direktori tidak ada: $dir"
    fi
done

# Backup system info
log "4. Backup system info..."

{
    echo "=== SERVER INFO ==="
    echo "Backup Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "=== SYSTEM ==="
    uname -a
    echo "=== DISK ==="
    df -h
    echo "=== MEMORY ==="
    free -h
} > system-info.txt

# compress backup (FINAL)
log "5. Kompresi backup final..."

cd $BACKUP_ROOT
FINAL_FILE="full-backup-$DATE.tar.gz"

if tar czf "$FINAL_FILE" "full-backup-$DATE" 2>> $LOG_FILE; then
    FINAL_SIZE=$(du -h "$FINAL_FILE" | cut -f1)
    log "    Backup terkompresi: $FINAL_FILE ($FINAL_SIZE)"
    rm -rf "full-backup-$DATE"
else
    error_exit "Gagal kompres backup"
fi

# Cleanup backup yang lama
log "6. Hapus backup lama..."

find $BACKUP_ROOT -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete -print | while read file; do
    log "    Hapus: $(basename $file)"
done

# Final REPORT
echo "===========================================" | tee -a $LOG_FILE
echo "BACKUP SERVER SELESAI" | tee -a $LOG_FILE
echo "File: $FINAL_FILE" | tee -a $LOG_FILE
echo "Size: $FINAL_SIZE" | tee -a $LOG_FILE
echo "Retention: $RETENTION_DAYS hari" | tee -a $LOG_FILE
echo "Log: $LOG_FILE" | tee -a $LOG_FILE
echo "===========================================" | tee -a $LOG_FILE

exit 0
