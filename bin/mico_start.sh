#!/data/data/com.termux/files/usr/bin/bash

echo "=== MICO SAFE START ==="

BASE="$HOME/JDEQ"

mkdir -p "$BASE/logs" "$BASE/runtime"

# lock sederhana
LOCK="$BASE/runtime/mico.lock"

if [ -f "$LOCK" ]; then
  echo "[STOP] already running"
  exit 1
fi

touch "$LOCK"

echo "[OK] system alive (no agents yet)"
echo "[INFO] safe mode active"

