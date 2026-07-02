#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/remote_heal.log"
if ! ssh -o ConnectTimeout=3 -p 8022 100.103.39.81 "pgrep -f ghost_relay.py" 2>/dev/null; then
  echo "[$(date)] Ghost Relay Infinix mati — restart via SSH" >> $LOG
  ssh -o ConnectTimeout=5 -p 8022 100.103.39.81 "cd ~/JDEQ_CLONE/bridge && nohup python3 ghost_relay.py > /dev/null 2>&1 &" 2>/dev/null \
    && echo "[$(date)] ✅ Berhasil restart" >> $LOG \
    || echo "[$(date)] ❌ Gagal" >> $LOG
fi
