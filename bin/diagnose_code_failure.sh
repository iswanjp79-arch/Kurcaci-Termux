#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/code_failure_$(date +%Y%m%d_%H%M).log"
FAIL_COUNT_FILE="$HOME/JDEQ/logs/code_failure_count.txt"

# Hitung jumlah kegagalan
FAIL_COUNT=$(cat "$FAIL_COUNT_FILE" 2>/dev/null || echo 0)
FAIL_COUNT=$((FAIL_COUNT + 1))
echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"

echo "============================================" | tee -a $LOG
echo " DIAGNOSA KEGAGALAN KODE #$FAIL_COUNT" | tee -a $LOG
echo " Waktu: $(date '+%d %B %Y, %H:%M:%S')" | tee -a $LOG
echo "============================================" | tee -a $LOG

# 1. Cek RAM
echo "1. RAM:" | tee -a $LOG
free -m | head -2 | tee -a $LOG

# 2. Cek disk
echo "2. Disk:" | tee -a $LOG
df -h ~ | tail -1 | tee -a $LOG

# 3. Cek proses berjalan
echo "3. Proses Termux:" | tee -a $LOG
ps aux | grep -E "bash|python|node" | grep -v grep | wc -l | xargs echo "   Total:" | tee -a $LOG

# 4. Cek koneksi
echo "4. Koneksi:" | tee -a $LOG
ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1 && echo "   Internet: OK" | tee -a $LOG || echo "   Internet: PUTUS" | tee -a $LOG

# 5. Cek LLM
echo "5. LLM:" | tee -a $LOG
pgrep llama-server > /dev/null 2>&1 && echo "   LLM: HIDUP" | tee -a $LOG || echo "   LLM: MATI" | tee -a $LOG

# 6. Catat penyebab kemungkinan
echo "" | tee -a $LOG
echo "KEMUNGKINAN PENYEBAB:" | tee -a $LOG
echo "- Batas panjang platform" | tee -a $LOG
echo "- Timeout eksekusi" | tee -a $LOG
echo "- Karakter heredoc salah" | tee -a $LOG
echo "- Proses background terlalu banyak" | tee -a $LOG
echo "- RAM habis" | tee -a $LOG

echo "" | tee -a $LOG
echo "Total kegagalan tercatat: $FAIL_COUNT" | tee -a $LOG
echo "============================================" | tee -a $LOG

# Kirim notifikasi jika kegagalan kelipatan 5
if [ $((FAIL_COUNT % 5)) -eq 0 ]; then
  curl -s -X POST "https://api.telegram.org/bot8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8/sendMessage" \
    -d "chat_id=8702459215" \
    -d "text=⚠️ MICO: Kegagalan kode sudah $FAIL_COUNT kali. Perlu penanganan." 2>/dev/null
fi
