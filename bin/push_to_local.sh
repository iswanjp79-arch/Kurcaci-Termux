#!/data/data/com.termux/files/usr/bin/bash
PUSHGW="http://localhost:9091/metrics/job/mico/instance/$(hostname)"
LOG_FILE="$HOME/JDEQ/logs/push_local.log"
AUDIT_FILE="$HOME/JDEQ/audit/metric_audit.log"

echo "=== MICO METRIC PUSHER STARTED $(date) ===" >> "$LOG_FILE"

while true; do
  RAM_FREE=$(free -m | awk '/Mem/{print $7}')
  TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}' || echo 0)
  LLM=$(pgrep llama-server >/dev/null && echo 1 || echo 0)
  BRIDGE=$(pgrep -f pocketpal_node.js >/dev/null && echo 1 || echo 0)
  NGROK=$(pgrep ngrok >/dev/null && echo 1 || echo 0)
  INFINIX=$(ping -c 1 -W 2 100.103.39.81 >/dev/null 2>&1 && echo 1 || echo 0)
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Kirim metrik
  cat <<METRICS | curl -s -X POST --data-binary @- "$PUSHGW" 2>> "$LOG_FILE"
# HELP mico_ram_free_mb RAM bebas (MB)
# TYPE mico_ram_free_mb gauge
mico_ram_free_mb $RAM_FREE
# HELP mico_temp_celsius Suhu CPU
# TYPE mico_temp_celsius gauge
mico_temp_celsius $TEMP
# HELP mico_service_up Status layanan (1=up, 0=down)
# TYPE mico_service_up gauge
mico_service_up{service="llm"} $LLM
mico_service_up{service="bridge"} $BRIDGE
mico_service_up{service="ngrok"} $NGROK
mico_service_up{service="infinix"} $INFINIX
METRICS

  # Tulis audit
  echo "[$TIMESTAMP] ram_mb=$RAM_FREE temp_c=$TEMP llm=$LLM bridge=$BRIDGE ngrok=$NGROK infinix=$INFINIX" >> "$AUDIT_FILE"
  
  echo "[$(date '+%H:%M:%S')] Metrik terkirim → Pushgateway" >> "$LOG_FILE"
  sleep 60
done
