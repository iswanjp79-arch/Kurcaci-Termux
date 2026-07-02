#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/watchdog_infinix.log"
IP="100.103.39.81"

if ping -c 2 -W 3 $IP > /dev/null 2>&1; then
  echo "[$(date '+%H:%M')] ✅ Infinix hidup" >> $LOG
else
  echo "[$(date '+%H:%M')] ❌ INFINIX MATI — perlu dicek Mba Yuli" >> $LOG
  termux-tts-speak "Mas Iswan, Infinix di rumah Mba Yuli mati. Tolong telepon beliau." 2>/dev/null
fi
