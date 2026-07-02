#!/data/data/com.termux/files/usr/bin/bash
# Circuit Breaker wrapper – cek status sebelum eksekusi
CB_FILE="/data/data/com.termux/files/home/JDEQ/circuit_breaker/cb_state.json"
FAILURE_COUNT=$(jq '.failure_count' "$CB_FILE" 2>/dev/null || echo 0)
THRESHOLD=$(jq '.threshold' "$CB_FILE" 2>/dev/null || echo 5)
if [ "$FAILURE_COUNT" -ge "$THRESHOLD" ]; then
    echo "Circuit Breaker OPEN – skip eksekusi"
    exit 1
fi
# Eksekusi perintah asli
"$@"
EXIT=$?
if [ $EXIT -ne 0 ]; then
    jq ".failure_count = $((FAILURE_COUNT+1))" "$CB_FILE" > "$CB_FILE.tmp" && mv "$CB_FILE.tmp" "$CB_FILE"
else
    jq '.failure_count = 0' "$CB_FILE" > "$CB_FILE.tmp" && mv "$CB_FILE.tmp" "$CB_FILE"
fi
exit $EXIT
