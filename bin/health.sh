#!/data/data/com.termux/files/usr/bin/bash
set -u
BASE="$HOME/JDEQ"
LOG="$BASE/logs"
STATE="$BASE/runtime/state.json"

mkdir -p "$LOG" "$BASE/runtime"
ts="$(date '+%F %T')"

# Cek proses
alive="no"
pgrep -x mosquitto >/dev/null 2>&1 && alive="yes"

# Cek fungsi: publish-subscribe loop
mqtt_ok="no"
if command -v mosquitto_pub >/dev/null 2>&1; then
    mosquitto_pub -h 127.0.0.1 -p 1883 -t "JDEQ/health" -m "ping" -u jdeq -P jdeq_mqtt_secure >/dev/null 2>&1 && mqtt_ok="yes"
fi

echo "[$ts] alive=$alive mqtt_ok=$mqtt_ok" >> "$LOG/health.log"

if [ "$alive" = "yes" ] && [ "$mqtt_ok" = "yes" ]; then
    echo '{"status":"healthy","last_health":"'$ts'","recover_count":0}' > "$STATE"
    exit 0
fi

# Panggil recovery
bash "$BASE/bin/recover.sh"
