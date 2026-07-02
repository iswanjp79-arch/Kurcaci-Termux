#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/security.log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }
stamp "Security check mulai"

# Cek permission API key
if [ -f "$HOME/JDEQ/config/api_keys.txt" ]; then
    perm=$(stat -c %a $HOME/JDEQ/config/api_keys.txt)
    [ "$perm" != "600" ] && chmod 600 $HOME/JDEQ/config/api_keys.txt && stamp "API key dikunci"
fi

# Proses mencurigakan
if ps aux | grep -v grep | grep -qE "cryptominer|xmrig|stratum"; then
    stamp "PROSES MENCURIGAKAN TERDETEKSI!"
fi

# Circuit breaker
ERRORS=$(grep -c "ERROR\|KRITIS" $LOG 2>/dev/null || true)
if [ "$ERRORS" -gt 10 ]; then
    stamp "CIRCUIT BREAKER: ${ERRORS} error → sleep 10 menit"
    sleep 600
fi
stamp "Security check selesai"
