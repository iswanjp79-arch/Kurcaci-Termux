#!/data/data/com.termux/files/usr/bin/bash
# Bootstrap only — tidak ada logika utama
termux-wake-lock >/dev/null 2>&1 || true
if command -v sv >/dev/null 2>&1; then
    sv up mosquitto >/dev/null 2>&1 || true
else
    mosquitto -c ~/JDEQ/config/mosquitto.conf -d >/dev/null 2>&1 || true
fi
echo "[$(date)] Bootstrap selesai" >> ~/JDEQ/logs/boot.log
