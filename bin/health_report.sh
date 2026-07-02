#!/data/data/com.termux/files/usr/bin/bash
REPORT="$HOME/JDEQ/logs/health_report_$(date +%Y%m%d).log"
echo "=== MICO HEALTH REPORT $(date) ===" > $REPORT
bash ~/JDEQ/bin/dashboard.sh >> $REPORT 2>&1
echo "Laporan tersimpan: $REPORT"
