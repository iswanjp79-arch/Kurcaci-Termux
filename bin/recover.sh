#!/data/data/com.termux/files/usr/bin/bash
set -u
BASE="$HOME/JDEQ"
LOG="$BASE/logs"
STATE="$BASE/runtime/state.json"
MAX_RESTARTS=5
COOLDOWN=600

mkdir -p "$LOG" "$BASE/runtime"
ts="$(date '+%F %T')"

# Baca recovery count
count=0
if [ -f "$STATE" ]; then
    count=$(python3 -c "import json; d=json.load(open('$STATE')); print(d.get('recover_count',0))" 2>/dev/null || echo 0)
fi

# Backoff jika terlalu banyak restart
if [ "$count" -ge "$MAX_RESTARTS" ]; then
    echo "[$ts] COOLDOWN — terlalu banyak restart ($count)" >> "$LOG/recover.log"
    sleep "$COOLDOWN"
    count=0
fi

echo "[$ts] Recovery attempt $((count+1))" >> "$LOG/recover.log"

# Restart via termux-services atau manual
if command -v sv >/dev/null 2>&1; then
    sv down mosquitto >/dev/null 2>&1 || true
    sleep 2
    sv up mosquitto >/dev/null 2>&1 || true
else
    pkill -x mosquitto >/dev/null 2>&1 || true
    sleep 2
    mosquitto -c "$BASE/config/mosquitto.conf" -d >/dev/null 2>&1 || true
fi

sleep 3

# Cek hasil
if pgrep -x mosquitto >/dev/null 2>&1; then
    result="recovered"
    next_count=0
else
    result="failed"
    next_count=$((count+1))
fi

# Update state
python3 -c "
import json
d={'last_recover':'$ts','recover_count':$next_count,'recover_result':'$result'}
json.dump(d, open('$STATE','w'), indent=2)
"

echo "[$ts] Recovery result=$result next_count=$next_count" >> "$LOG/recover.log"
