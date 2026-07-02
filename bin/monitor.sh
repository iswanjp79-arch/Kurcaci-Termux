#!/bin/bash
THRESHOLD_RAM=85
LOG_FILE="$HOME/JDEQ/logs/monitor.log"
mkdir -p "$(dirname "$LOG_FILE")"
while true; do
  RAM=$(free -m | grep Mem | awk '{print ($3/$2)*100}')
  if (( $(echo "$RAM > $THRESHOLD_RAM" | bc -l) )); then
    echo "[$(date)] ⚠️ RAM tinggi: $RAM%" >> "$LOG_FILE"
    echo "reduce_parallelism" > ~/JDEQ/RUNTIME/monitor/action.flag
  fi
  if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}')
    if (( $(echo "$TEMP > 55" | bc -l) )); then
      echo "[$(date)] ⚠️ Suhu tinggi: ${TEMP}°C" >> "$LOG_FILE"
      echo "pause_noncritical" > ~/JDEQ/RUNTIME/monitor/action.flag
    fi
  fi
  for proc in mosquitto llama-server task_worker.py; do
    if ! pgrep -f "$proc" >/dev/null; then
      echo "[$(date)] ❌ $proc mati, restart..." >> "$LOG_FILE"
      case $proc in
        mosquitto) cd ~/JDEQ/mqtt && ./start_mqtt.sh ;;
        llama-server) cd ~/JDEQ && nohup llama-server -m ~/models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf --host 127.0.0.1 --port 8082 -c 256 -t 1 --no-warmup -ngl 0 >> log/llama_server.log 2>&1 & ;;
        task_worker.py) cd ~/JDEQ && nohup python3 task_worker.py >> log/task_worker.log 2>&1 & ;;
      esac
    fi
  done
  sleep 30
done
