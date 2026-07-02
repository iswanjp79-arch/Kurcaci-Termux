#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/troubleshoot.log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }
stamp "Troubleshoot mulai"

# MICO server mati?
if ! curl -s --max-time 3 http://localhost:8082/v1/models > /dev/null; then
    stamp "MICO mati, restart..."
    pkill -f "llama.*server" 2>/dev/null; sleep 2
    nohup bash $HOME/JDEQ/start_mico.sh >> $HOME/JDEQ/logs/mico_server.log 2>&1 &
    sleep 10
    curl -s --max-time 5 http://localhost:8082/v1/models > /dev/null && stamp "MICO hidup" || stamp "Restart gagal"
fi

# RAM < 300MB?
FREE=$(free -m | awk '/Mem/{print $7}')
if [ "$FREE" -lt 300 ]; then
    stamp "RAM kritis: ${FREE}MB"
    sync; echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    pkill -f chrome 2>/dev/null || true
    stamp "RAM sekarang: $(free -m | awk '/Mem/{print $7}')MB"
fi

# Storage > 85%?
DISK=$(df $HOME | awk 'NR==2{print $5}' | tr -d '%')
if [ "$DISK" -gt 85 ]; then
    stamp "Storage ${DISK}% → bersihkan log lama"
    find $HOME/JDEQ/logs -name "*.log" -mtime +7 -delete
    find $HOME/JDEQ/backup -name "config_*" | sort | head -n -3 | xargs rm -rf 2>/dev/null
    stamp "Pembersihan selesai"
fi

# SSOT hash
if [ -f "$HOME/JDEQ/HASH_SEAL/integrity.sha256" ]; then
    sha256sum -c $HOME/JDEQ/HASH_SEAL/integrity.sha256 > /dev/null 2>&1 && stamp "SSOT UTUH" || stamp "PERINGATAN: SSOT BERUBAH!"
fi
stamp "Troubleshoot selesai"
