#!/bin/bash
GATEWAY="ONLINE"
WORKER=$(pgrep -f task_worker.py >/dev/null && echo "ONLINE" || echo "OFFLINE")
MQTT=$(pgrep -f mosquitto >/dev/null && echo "ONLINE" || echo "OFFLINE")
if [ -f /sdcard/NixBridge/listener.pid ]; then
  PID=$(cat /sdcard/NixBridge/listener.pid)
  kill -0 "$PID" 2>/dev/null && NIX="CONNECTED" || NIX="OFFLINE"
else
  NIX="OFFLINE"
fi
QUEUE=$(jq length ~/JDEQ/queue/tasks.json 2>/dev/null || echo 0)
echo "========================="
echo "  MICO CORE"
echo "========================="
echo "GATEWAY  : $GATEWAY"
echo "WORKER   : $WORKER"
echo "MQTT     : $MQTT"
echo "NIX      : $NIX"
echo "QUEUE    : $QUEUE task"
echo "========================="
