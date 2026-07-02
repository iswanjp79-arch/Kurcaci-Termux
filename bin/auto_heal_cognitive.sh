#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/auto_heal_cognitive.log"
echo "[$(date)] Cognitive heal start" >> $LOG
python3 ~/JDEQ/DAL/identity_engine.py >> $LOG 2>&1
python3 ~/JDEQ/DAL/predictive_planner.py >> $LOG 2>&1
python3 ~/JDEQ/DAL/meta_cognitive.py >> $LOG 2>&1
echo "[$(date)] Cognitive heal done" >> $LOG
