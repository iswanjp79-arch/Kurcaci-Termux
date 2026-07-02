#!/data/data/com.termux/files/usr/bin/bash
LOG=~/JDEQ/logs/pantau_dola.log
RAM=$(free -m | awk '/Mem/{print $7}')
LLM=$(pgrep llama-server >/dev/null && echo 1 || echo 0)
BRIDGE=$(pgrep -f pocketpal_node.js >/dev/null && echo 1 || echo 0)
INFI=$(ping -c1 -W2 100.103.39.81 >/dev/null 2>&1 && echo 1 || echo 0)
OK=1
[ "$RAM" -lt 2000 ] && OK=0
[ "$LLM" -eq 0 ] && OK=0
[ "$BRIDGE" -eq 0 ] && OK=0
[ "$INFI" -eq 0 ] && OK=0
if [ "$OK" -eq 1 ]; then
  echo "[$(date)] ✅ SEMUA SYARAT TERPENUHI (RAM=${RAM}MB LLM=${LLM} Bridge=${BRIDGE} Infinix=${INFI})" >> "$LOG"
else
  echo "[$(date)] ⚠️ PELANGGARAN SYARAT (RAM=${RAM}MB LLM=${LLM} Bridge=${BRIDGE} Infinix=${INFI})" >> "$LOG"
fi
