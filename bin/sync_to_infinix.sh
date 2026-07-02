#!/data/data/com.termux/files/usr/bin/bash
INFINIX_IP="100.103.39.81"
LOG="$HOME/JDEQ/logs/sync_infinix.log"

# Sinkronkan SSOT
rsync -az --delete ~/JDEQ/SSOT/ ${INFINIX_IP}:~/JDEQ_CLONE/MIRROR/SSOT/ 2>/dev/null && \
  echo "[$(date)] ✅ SSOT tersinkron" >> $LOG || \
  echo "[$(date)] ⚠️ Infinix tidak terjangkau" >> $LOG

# Sinkronkan audit trail
rsync -az ~/JDEQ/logs/audit_*.log ${INFINIX_IP}:~/JDEQ_CLONE/MIRROR/logs/ 2>/dev/null

# Sinkronkan config
rsync -az ~/JDEQ/config/ ${INFINIX_IP}:~/JDEQ_CLONE/MIRROR/config/ 2>/dev/null
