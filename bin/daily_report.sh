#!/data/data/com.termux/files/usr/bin/bash
REPORT_FILE="$HOME/JDEQ/logs/daily_report_$(date +%Y%m%d).txt"

echo "========================================" > $REPORT_FILE
echo " LAPORAN HARIAN MICO-JDEQ" >> $REPORT_FILE
echo " Tanggal: $(date)" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
bash ~/JDEQ/bin/dashboard.sh >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE
echo "📋 Keputusan hari ini:" >> $REPORT_FILE
python3 -c "
import os, json
log = os.path.expanduser('~/JDEQ/cognitive/decision/decisions.jsonl')
if os.path.exists(log):
    with open(log) as f:
        lines = f.readlines()
    for l in lines[-5:]:
        d = json.loads(l)
        print(f\"  - {d['chosen']} ({d['reason']})\")
" >> $REPORT_FILE 2>&1

# Kirim ke Telegram
bash ~/JDEQ/bin/notify_telegram.sh "$(head -20 $REPORT_FILE)" 2>/dev/null

# Kirim ke WhatsApp
termux-share -a send -f $REPORT_FILE 2>/dev/null || true

echo "✅ Laporan harian tersimpan: $REPORT_FILE"
