#!/data/data/com.termux/files/usr/bin/bash
BACKUP_DIR=~/JDEQ_BACKUP_$(date +%Y%m%d_%H%M)
mkdir -p "$BACKUP_DIR"
rsync -av --exclude='models/' --exclude='*.gguf' ~/JDEQ/ "$BACKUP_DIR/JDEQ/" 2>/dev/null
crontab -l > "$BACKUP_DIR/crontab.txt" 2>/dev/null
cp ~/JDEQ/MICO_LIFECYCLE/mico_state.db "$BACKUP_DIR/" 2>/dev/null
echo "$(date): Backup created at $BACKUP_DIR" >> ~/JDEQ/logs/backup.log
# Rotasi: simpan 5 versi terakhir
ls -dt ~/JDEQ_BACKUP_* | tail -n +6 | xargs rm -rf 2>/dev/null
