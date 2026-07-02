#!/data/data/com.termux/files/usr/bin/bash
# Catat semua keputusan yang diambil sistem
echo "[$(date)] Audit keputusan" >> ~/JDEQ/logs/decision_audit.log
python3 -c "
import os, json
log_file = os.path.expanduser('~/JDEQ/cognitive/decision/decisions.jsonl')
if os.path.exists(log_file):
    with open(log_file) as f:
        lines = f.readlines()
    print(f'Total keputusan: {len(lines)}')
    if lines:
        last = json.loads(lines[-1])
        print(f'Keputusan terakhir: {last[\"chosen\"]} ({last[\"reason\"]})')
" >> ~/JDEQ/logs/decision_audit.log 2>&1
