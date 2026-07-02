#!/data/data/com.termux/files/usr/bin/bash
# Dispatcher Safe — Verifikasi node sebelum eksekusi
NODE_REGISTRY=~/JDEQ/NODE_REGISTRY/nodes.json
AUDIT_LOG=~/JDEQ/logs/dispatcher_audit.log
NODE_ID="$1"
TASK="$2"

# Cek apakah node terdaftar
if python3 -c "import json,sys; nodes=json.load(open('$NODE_REGISTRY')); sys.exit(0 if any(n['name']=='$NODE_ID' for n in nodes['nodes']) else 1)" ; then
    echo "$(date): NODE=$NODE_ID TASK=$TASK STATUS=approved" >> "$AUDIT_LOG"
    # Eksekusi tugas yang diizinkan
    ~/JDEQ/bin/nix_worker_safe.sh "$TASK"
else
    echo "$(date): NODE=$NODE_ID TASK=$TASK STATUS=rejected (unknown node)" >> "$AUDIT_LOG"
    echo "Node tidak dikenal: $NODE_ID" >&2
    exit 1
fi
