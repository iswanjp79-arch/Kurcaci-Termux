#!/data/data/com.termux/files/usr/bin/bash
# Watchdog JDEQ — recovery otomatis ringan
MAX_RESTART=3
RESTART_COUNT=0

restart_if_down() {
    local proc=$1
    local cmd=$2
    if ! pgrep -f "$proc" > /dev/null; then
        echo "$(date) Restarting $proc"
        eval "$cmd" &
        ((RESTART_COUNT++))
    fi
}

# Cek llama-server
restart_if_down "llama-server" "llama-server -m ~/models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf --host 127.0.0.1 --port 8082 -c 256 -t 1 --no-warmup -ngl 0 >> ~/JDEQ/log/llama_server.log 2>&1"

# Cek task_worker
restart_if_down "task_worker" "cd ~/JDEQ && python3 task_worker.py >> ~/JDEQ/log/task_worker.log 2>&1"

if [ $RESTART_COUNT -gt 0 ]; then
    echo "$(date) Watchdog melakukan $RESTART_COUNT restart" >> ~/JDEQ/log/watchdog.log
fi
