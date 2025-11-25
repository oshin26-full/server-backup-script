Script ini digunakan untuk melakukan backup penuh pada server Ubuntu secara otomatis. Proses backup mencakup database MySQL, direktori penting, file konfigurasi, dan informasi sistem. Hasil backup dikompresi menjadi satu file .tar.gz dan backup lama dihapus secara otomatis berdasarkan pengaturan retensi.

Fitur Utama :
* Backup semua database MySQL (kecuali database sistem).
* Backup file konfigurasi penting seperti /etc/passwd, /etc/group, /etc/fstab, dan /etc/hosts.
* Backup direktori penting seperti /etc, /home, dan /var/www.
* Menyimpan informasi server (disk, memori, kernel, hostname).
* Menghasilkan file backup kompresi dalam format full-backup-YYYYMMDD_HHMMSS.tar.gz.
* Menghapus backup lama berdasarkan jumlah hari retensi.
* Semua proses dicatat dalam file log.
* Auto backup server lengkap setiap hari
* Monitoring & alerting
* Retention policy (7 hari)
* Restore capability
* Detailed logging

Penggunaannya : 
1. Edit konfigurasi di dalam script (user MySQL, password, directory backup).
2. Beri permission: chmod +x server-backup.sh
3. Beri permission: chmod +x check-backup.sh
4. Beri permission: chmod +x test-backup.sh
3. Jalankan: sudo ./server-backup.sh

Cron Job (optional) : 
pakai # di depannya mengikuti script cronjob defaultnya.

* m h  dom mon dow   command
* Auto Backup Server - Daily at 2 AM (untuk backup setiap jam 2 pagi)
* 0 2 * * * /usr/local/bin/server-backup.sh
* Auto Backup Server - Weekly on Sunday at 3 AM (untuk backup mingguan di hari minggu jam 3 pagi)  
* 0 3 * * 0 /usr/local/bin/server-backup.sh
