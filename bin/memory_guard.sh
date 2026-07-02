#!/data/data/com.termux/files/usr/bin/bash
MEM_FILE="/data/data/com.termux/files/home/JDEQ/logs/memory.log"
THRESHOLD=300
while true; do
    FREE=$(free -m | awk '/Mem:/ {print $4}')
    if [ "$FREE" -lt "$THRESHOLD" ]; then
        echo "$(date) - RAM kritis: ${FREE}MB, stop inference" >> "$MEM_FILE"
        pkill -f "llama-server" 2>/dev/null
        sleep 5
        nohup llama-server -m /storage/emulated/0/AI_Models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf --host 0.0.0.0 --port 8082 --ctx-size 2048 -ngl 0 -t 1 > ~/JDEQ/logs/mico_server_2048.log 2>&1 &
    fi
    sleep 30
done
