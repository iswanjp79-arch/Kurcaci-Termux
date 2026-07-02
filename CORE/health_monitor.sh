#!/data/data/com.termux/files/usr/bin/bash
# Health Monitor JDEQ — cek vital sistem
LOG=~/JDEQ/LOG/health_monitor.log
echo "$(date) ==========" >> $LOG
echo "CPU: $(uptime)" >> $LOG
echo "RAM: $(free -m | grep Mem)" >> $LOG
echo "Disk: $(df -h /data | tail -1)" >> $LOG
echo "Suhu: $(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 || echo 'N/A')" >> $LOG
echo "llama-server: $(pgrep -f llama-server || echo 'OFF')" >> $LOG
echo "task_worker: $(pgrep -f task_worker || echo 'OFF')" >> $LOG
echo "MICO: $(pgrep -f mico_chat || echo 'OFF')" >> $LOG
