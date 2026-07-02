#!/data/data/com.termux/files/usr/bin/bash
LOG=~/JDEQ/logs/watchdog.log
# Cek dan restart Ghost Relay
if ! pgrep -f ghost_relay.py > /dev/null; then
    nohup python3 ~/JDEQ/bridge/ghost_relay.py > /dev/null 2>&1 &
    echo "$(date): Ghost Relay restarted" >> "$LOG"
fi
# Cek dan restart llama-server
if ! pgrep -f llama-server > /dev/null; then
    nohup llama-server -m ~/models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf \
        --host 127.0.0.1 --port 8082 -c 256 -t 1 --no-warmup -ngl 0 > /dev/null 2>&1 &
    echo "$(date): llama-server restarted" >> "$LOG"
fi
