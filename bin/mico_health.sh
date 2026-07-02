#!/data/data/com.termux/files/usr/bin/bash
# MICO Health Monitor – cek suhu, baterai, beban CPU

LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/health.log"
BATTERY=$(termux-battery-status 2>/dev/null | grep -o '"percentage":[0-9]*' | cut -d: -f2)
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | cut -c1-2)
LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)

# Jika battery tidak terbaca, default ke 100
[ -z "$BATTERY" ] && BATTERY=100
[ -z "$TEMP" ] && TEMP=40
[ -z "$LOAD" ] && LOAD=0.0

echo "$(date '+%Y-%m-%d %H:%M:%S') | BATERAI: ${BATTERY}% | SUHU: ${TEMP}°C | LOAD: ${LOAD}" >> "$LOG_FILE"

# Kirim ke MICO melalui file state
echo "{\"battery\":$BATTERY,\"temp\":$TEMP,\"load\":$LOAD}" > /data/data/com.termux/files/home/JDEQ/config/health.json
