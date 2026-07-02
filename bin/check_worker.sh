#!/bin/bash
if pgrep -f "python3.*task_worker.py" > /dev/null; then
    echo "ONLINE (PID: $(pgrep -f 'python3.*task_worker.py' | head -1))"
else
    echo "OFFLINE"
fi
