#!/bin/bash
# JDEQ Status Dashboard (tidak mengganggu MICO)

echo "=============================="
echo "    JDEQ STATUS DASHBOARD"
echo "=============================="
echo ""

GATEWAY=$($HOME/JDEQ/bin/check_gateway.sh 2>/dev/null || echo "ERROR")
WORKER=$($HOME/JDEQ/bin/check_worker.sh 2>/dev/null || echo "OFFLINE")
MQTT=$($HOME/JDEQ/bin/check_mqtt.sh 2>/dev/null || echo "OFFLINE")
NIX=$($HOME/JDEQ/bin/check_nix.sh 2>/dev/null || echo "UNKNOWN")
BRIDGE=$($HOME/JDEQ/bin/check_bridge.sh 2>/dev/null || echo "OFFLINE")
PENDING=$($HOME/JDEQ/bin/check_queue.sh 2>/dev/null || echo "0")

echo "GATEWAY      : $GATEWAY"
echo "TASK WORKER  : $WORKER"
echo "MQTT         : $MQTT"
echo "NIX          : $NIX"
echo "BRIDGE       : $BRIDGE"
echo ""
echo "PENDING TASK : $PENDING"
echo "RUNNING TASK : $(pgrep -f 'python3.*task_worker' 2>/dev/null | wc -l)"
echo ""
echo "=============================="
