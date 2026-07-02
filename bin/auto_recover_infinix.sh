#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/auto_recover_infinix.log"
IP="100.103.39.81"

echo "[$(date '+%H:%M:%S')] Memeriksa Infinix..." >> $LOG

# Cek apakah Infinix offline
if ! ping -c 2 -W 3 $IP > /dev/null 2>&1; then
  echo "[$(date '+%H:%M:%S')] ❌ Infinix OFFLINE — mencoba pemulihan otomatis..." >> $LOG
  
  # Langkah 1: Coba hidupkan server via SSH
  ssh -o ConnectTimeout=5 -p 8022 $IP "termux-wake-lock acquire && cd ~/JDEQ_CLONE/server && nohup python3 mico_server.py > /dev/null 2>&1 &" 2>/dev/null
  
  sleep 5
  
  # Langkah 2: Cek ulang
  if ping -c 2 -W 3 $IP > /dev/null 2>&1; then
    echo "[$(date '+%H:%M:%S')] ✅ Infinix PULIH — berhasil diaktifkan" >> $LOG
    termux-tts-speak "Infinix berhasil dipulihkan." 2>/dev/null
  else
    echo "[$(date '+%H:%M:%S')] ❌ Infinix masih OFFLINE — perlu pengecekan manual" >> $LOG
    termux-tts-speak "Mas Iswan, Infinix masih mati. Tolong cek layarnya." 2>/dev/null
    bash ~/JDEQ/bin/notify_telegram.sh "⚠️ AUTO-RECOVERY GAGAL: Infinix masih offline. Perlu dicek manual." 2>/dev/null
  fi
else
  echo "[$(date '+%H:%M:%S')] ✅ Infinix ONLINE" >> $LOG
fi
