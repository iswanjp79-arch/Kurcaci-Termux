#!/bin/bash
BRIDGE_DIR="$HOME/storage/shared/NixBridge"
mkdir -p "$BRIDGE_DIR"
TASK_FILE="$BRIDGE_DIR/task.txt"
RESULT_FILE="$BRIDGE_DIR/result.txt"

if [ -z "$1" ]; then
    echo "Usage: nix_send.sh 'perintah'"
    exit 1
fi

echo "$1" > "$TASK_FILE"

TIMEOUT=15
while [ ! -f "$RESULT_FILE" ] && [ $TIMEOUT -gt 0 ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT-1))
done

if [ -f "$RESULT_FILE" ]; then
    cat "$RESULT_FILE"
    rm -f "$RESULT_FILE"
else
    echo "ERROR: Timeout menunggu respons dari Nix"
    exit 1
fi
