#!/data/data/com.termux/files/usr/bin/bash
DATE=$(date +%Y%m%d_%H%M)
SNAP_DIR="$HOME/JDEQ/backup/snapshots/$DATE"
mkdir -p $SNAP_DIR
cp ~/JDEQ/cognitive/knowledge/knowledge.db $SNAP_DIR/ 2>/dev/null
cp ~/JDEQ/cognitive/learning/patterns.json $SNAP_DIR/ 2>/dev/null
cp ~/JDEQ/cognitive/decision/decisions.jsonl $SNAP_DIR/ 2>/dev/null
cp -r ~/JDEQ/DAL $SNAP_DIR/ 2>/dev/null
echo "[$(date)] Snapshot tersimpan: $SNAP_DIR" >> ~/JDEQ/logs/snapshot.log
