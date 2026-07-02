#!/data/data/com.termux/files/usr/bin/bash
NARRATIVE="$HOME/JDEQ/logs/narrative_$(date +%Y%m%d).md"
echo "# 📖 LAPORAN HARIAN MICO — $(date '+%d %B %Y')" > $NARRATIVE
echo "" >> $NARRATIVE
echo "Hari ini saya menerima **$(cat ~/JDEQ/AUDIT/predictions.jsonl 2>/dev/null | wc -l)** prediksi." >> $NARRATIVE
echo "Saya melakukan **$(cat ~/JDEQ/AUDIT/meta_cognitive.jsonl 2>/dev/null | wc -l)** refleksi diri." >> $NARRATIVE
echo "RAM bebas: **$(free -m | awk '/Mem/{print $7}') MB**." >> $NARRATIVE
echo "Infinix: **$(ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1 && echo 'TERHUBUNG' || echo 'TIDAK TERHUBUNG')**." >> $NARRATIVE
echo "" >> $NARRATIVE
echo "✅ Laporan tersimpan: $NARRATIVE"
bash ~/JDEQ/bin/notify_telegram.sh "📖 Laporan harian MICO siap" 2>/dev/null
