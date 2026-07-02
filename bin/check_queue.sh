#!/bin/bash
TASK_FILE="$HOME/JDEQ/queue/tasks.json"
if [ -f "$TASK_FILE" ]; then
    PENDING=$(jq length "$TASK_FILE" 2>/dev/null || echo 0)
    echo "$PENDING"
else
    echo "0"
fi
