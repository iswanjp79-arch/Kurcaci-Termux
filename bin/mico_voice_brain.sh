#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/mico_voice.log"
echo "MICO siap mendengarkan..."

while true; do
  # Merekam suara dan mengubahnya jadi teks
  echo "🎤 Bicara sekarang..."
  PERINTAH=$(termux-speech-to-text 2>/dev/null)
  
  if [ -n "$PERINTAH" ]; then
    echo "[$(date)] Terdeteksi: $PERINTAH" >> $LOG
    
    # Otak MICO yang memutuskan tindakan
    if echo "$PERINTAH" | grep -q "lihat\|foto\|potret"; then
      echo "📷 Menjalankan: Ambil Foto"
      bash ~/JDEQ/bin/mico_master_bridge.sh lihat
      
    elif echo "$PERINTAH" | grep -q "lapor\|laporkan\|kabar"; then
      echo "📊 Menjalankan: Buat Laporan"
      bash ~/JDEQ/bin/laporan_dewan.sh
      
    elif echo "$PERINTAH" | grep -q "sehat\|cek\|cek kesehatan"; then
      echo "🩺 Menjalankan: Cek Kesehatan"
      bash ~/JDEQ/bin/health_check.sh
      
    else
      echo "🤔 Perintah tidak dikenali, melanjutkan mendengar..."
    fi
  fi
  
  # Jeda sebentar sebelum mendengar lagi
  sleep 2
done
