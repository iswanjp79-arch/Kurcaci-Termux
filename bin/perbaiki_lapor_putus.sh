#!/data/data/com.termux/files/usr/bin/bash
LOG=~/JDEQ/logs/jaringan.log
BATAS_PESAN=3
HITUNG=$(grep -c "Infinix OFFLINE" $LOG 2>/dev/null || echo 0)

if ping -c 1 -W 2 100.103.39.81 &>/dev/null; then
  echo "[$(date)] ✅ Infinix TERSAMBUNG KEMBALI" >> $LOG
  termux-notification --title "MICO-JDEQ" --content "Infinix sudah pulih. Koneksi normal."
  exit 0
fi

if [ $HITUNG -lt $BATAS_PESAN ]; then
  echo "[$(date)] ⚠️ Infinix OFFLINE — kirim notifikasi ke-$((HITUNG+1))" >> $LOG
  termux-notification --title "MICO-JDEQ" --content "Infinix OFFLINE. Cek colokan charger."
else
  echo "[$(date)] 🔇 Masih terputus — notifikasi dihentikan sementara" >> $LOG
fi
