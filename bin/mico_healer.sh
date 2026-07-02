#!/bin/bash
LOG=~/JDEQ/logs/healer.log
log() { echo "[$(date)] $1" >> "$LOG"; }

# Plan A: Cek proses orchestrator
if pgrep -f unified_orchestrator.py > /dev/null; then
    log "Plan A: Orchestrator berjalan normal."
    exit 0
fi

log "Plan A gagal. Mencoba Plan B..."
# Plan B: Restart orchestrator
nohup python3 ~/JDEQ/CORE/unified_orchestrator.py > ~/JDEQ/logs/unified_orchestrator.log 2>&1 &
sleep 5
pgrep -f unified_orchestrator.py > /dev/null && log "Plan B: Orchestrator berhasil direstart." && exit 0

log "Plan B gagal. Mencoba Plan C..."
# Plan C: Cek Python, RAM, SSOT, Telegram
python3 -c "print('OK')" 2>/dev/null || log "Plan C: Python ERROR"
cat /proc/meminfo 2>/dev/null | head -1 || log "Plan C: Meminfo ERROR"
ls ~/JDEQ/SSOT/ 2>/dev/null | head -1 || log "Plan C: SSOT ERROR"
curl -s "https://api.telegram.org/bot8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8/getMe" | grep -q "ok" && log "Plan C: Telegram OK" || log "Plan C: Telegram ERROR"

log "Plan C selesai. Mencoba Plan D..."
# Plan D: Fallback minimal
python3 -c "
import subprocess, time
while True:
    with open('/proc/meminfo') as f:
        for line in f:
            if 'MemAvailable' in line:
                avail = int(line.split()[1]) // 1024
                if avail < 500:
                    subprocess.run(['curl', '-s', '-X', 'POST',
                        'https://api.telegram.org/bot8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8/sendMessage',
                        '-d', 'chat_id=8702459215',
                        '-d', f'text=RAM: {avail}MB'], capture_output=True)
    time.sleep(300)
" &
sleep 2
pgrep -f "python3 -c" > /dev/null && log "Plan D: Fallback minimal berjalan." && exit 0

log "Plan D gagal. Mencoba Plan E..."
# Plan E: Restorasi dari backup terakhir
BACKUP_DIR=$(ls -dt ~/JDEQ/backup/auto-* 2>/dev/null | head -1)
if [ -n "$BACKUP_DIR" ]; then
    cp -r "$BACKUP_DIR"/* ~/JDEQ/CORE/restore/ 2>/dev/null
    log "Plan E: Restorasi dari $BACKUP_DIR"
else
    log "Plan E: Tidak ada backup ditemukan."
fi

log "Semua plan selesai. Status: $(pgrep -f unified_orchestrator.py > /dev/null && echo 'HIDUP' || echo 'MATI')"
