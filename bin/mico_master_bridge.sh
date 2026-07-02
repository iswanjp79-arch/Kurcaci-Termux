#!/data/data/com.termux/files/usr/bin/bash
# JEMBATAN UTAMA MICO: MacroDroid hanya panggil ini SATU KALI
LOG="$HOME/JDEQ/logs/mico_master_bridge.log"
echo "[$(date '+%H:%M:%S')] DIPANGGIL" >> $LOG

# Fungsi untuk menjalankan aksi
jalankan() {
  echo "✅ Menjalankan: $1" | tee -a $LOG
  bash ~/JDEQ/bridge/macro_listener.sh "$1"
}

# Cek apa yang diminta MacroDroid
case "$1" in
  lihat)
    jalankan "capture"
    ;;
  lapor)
    bash ~/JDEQ/bin/laporan_dewan.sh
    ;;
  sehat)
    bash ~/JDEQ/bin/health_check.sh
    ;;
  update)
    bash ~/JDEQ/bin/auto_heal_network.sh
    ;;
  *)
    echo "⚠️ Perintah tidak dikenal: $1" >> $LOG
    ;;
esac
echo "[$(date '+%H:%M:%S')] SELESAI" >> $LOG
