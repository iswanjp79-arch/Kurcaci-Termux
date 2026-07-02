#!/data/data/com.termux/files/usr/bin/bash
# Hentikan proses berat jika suhu naik, gunakan wake lock
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}')
MAX_TEMP=45.0
if [ -n "$TEMP" ] && (( $(echo "$TEMP > $MAX_TEMP" | bc -l) )); then
    echo "$(date): SUHU TINGGI ($TEMP°C) — menghentikan proses berat" >> ~/JDEQ/logs/power.log
    pkill -STOP llama-server 2>/dev/null || true
    sleep 60
    pkill -CONT llama-server 2>/dev/null || true
else
    # Aktifkan wake lock agar CPU tidak tidur
    termux-wake-lock acquire 2>/dev/null || true
fi
