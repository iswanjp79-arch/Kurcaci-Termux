#!/bin/bash
# JDEQ Control Panel v1.0

echo "=============================="
echo "    JDEQ CONTROL PANEL"
echo "=============================="
echo ""

GATEWAY=$($HOME/JDEQ/bin/check_gateway.sh)
WORKER=$($HOME/JDEQ/bin/check_worker.sh)
MQTT=$($HOME/JDEQ/bin/check_mqtt.sh)
NIX=$($HOME/JDEQ/bin/check_nix.sh)
BRIDGE=$($HOME/JDEQ/bin/check_bridge.sh)
PENDING=$($HOME/JDEQ/bin/check_queue.sh)

echo "GATEWAY      : $GATEWAY"
echo "TASK WORKER  : $WORKER"
echo "MQTT         : $MQTT"
echo "NIX          : $NIX"
echo "BRIDGE       : $BRIDGE"
echo ""
echo "PENDING TASK : $PENDING"
echo "RUNNING TASK : $(pgrep -f 'python3.*task_worker' | wc -l)"
echo ""
echo "=============================="
