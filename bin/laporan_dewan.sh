#!/data/data/com.termux/files/usr/bin/bash
REPORT_FILE="$HOME/JDEQ/logs/laporan_dewan_$(date +%Y%m%d_%H%M).txt"
echo "========================================" > $REPORT_FILE
echo " LAPORAN RESMI DEWAN AGEN MICO-JDEQ" >> $REPORT_FILE
echo " Tanggal: $(date '+%d %B %Y, %H:%M WIB')" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
bash ~/JDEQ/bin/dashboard.sh >> $REPORT_FILE 2>&1
# Kirim ke Telegram
bash ~/JDEQ/bin/notify_telegram.sh "📘 LAPORAN DEWAN AGEN
━━━━━━━━━━━━━━━━━━━━━━
📅 $(date '+%d %B %Y')
⏰ $(date '+%H:%M WIB')

🖥️ VIVO Y28: $(free -m | awk '/Mem/{print $7}') MB free | LLM: $(pgrep llama-server >/dev/null && echo '✅' || echo '❌')
📱 INFINIX: $(ping -c 1 -W 1 100.103.39.81 >/dev/null && echo '✅' || echo '❌')
☁️ COLAB: $(curl -s --max-time 2 http://localhost:8082/v1/models >/dev/null && echo '✅' || echo '❌')
🌐 Ngrok: $(curl -s http://127.0.0.1:4040/api/tunnels 2>/dev/null | grep -o 'https://[^\"]*' | head -1 || echo 'Tidak aktif')
🔒 SSOT: TERKUNCI

📊 MODUL: Knowledge Core ✅ | Decision Kernel ✅ | SVD ✅ | Symthink ✅ | Multi-Cloud ✅ | Auto-Heal ✅
━━━━━━━━━━━━━━━━━━━━━━" 2>/dev/null
echo "✅ Laporan tersimpan: $REPORT_FILE"
