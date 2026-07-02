#!/bin/bash
BRIDGE_DIR="/sdcard/NixBridge"
TASK_FILE="$BRIDGE_DIR/task.txt"
RESULT_FILE="$BRIDGE_DIR/result.txt"
if [ -z "$1" ]; then echo "Usage: nix_executor.sh 'perintah'"; exit 1; fi
echo "$1" > "$TASK_FILE"
TIMEOUT=10
while [ ! -f "$RESULT_FILE" ] && [ $TIMEOUT -gt 0 ]; do sleep 1; TIMEOUT=$((TIMEOUT-1)); done
if [ -f "$RESULT_FILE" ]; then cat "$RESULT_FILE"; rm -f "$RESULT_FILE"; else echo "ERROR: Timeout menunggu Nix"; exit 1; fi
