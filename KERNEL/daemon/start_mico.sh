#!/data/data/com.termux/files/usr/bin/bash
# MICO Zero Touch — Dipanggil oleh MacroDroid saat Device Boot
# Fungsi: Membangunkan Decision Kernel & Event Bridge

LOG=~/JDEQ/KERNEL/logs/boot.log
mkdir -p $(dirname $LOG)

echo "[$(date)] MICO dibangunkan oleh MacroDroid" >> $LOG

# Verifikasi Mosquitto
if ! pgrep -x mosquitto > /dev/null; then
    mosquitto -d
    echo "[$(date)] Mosquitto dijalankan" >> $LOG
fi

sleep 2

# Verifikasi Decision Kernel
if ! pgrep -f decision_kernel.py > /dev/null; then
    python3 ~/JDEQ/KERNEL/decision_kernel.py &
    echo "[$(date)] Decision Kernel dijalankan" >> $LOG
fi

# Verifikasi Event Bridge Daemon
if ! pgrep -f event_bridge_daemon.py > /dev/null; then
    python3 ~/JDEQ/KERNEL/daemon/event_bridge_daemon.py &
    echo "[$(date)] Event Bridge Daemon dijalankan" >> $LOG
fi

# Verifikasi Ghost Runner
if ! pgrep -f ghost_runner.sh > /dev/null; then
    echo "[$(date)] Ghost Runner siap (via Decision Kernel)" >> $LOG
fi

# Kirim event ke Decision Kernel
MQTT_PASS="jdeq_3TUK1EkSahw"
mosquitto_pub -h 127.0.0.1 -t "jdeq/events" -u jdeq_mico -P "$MQTT_PASS" -m '{"event":"DEVICE_BOOT","source":"macrodroid","timestamp":"'$(date -Iseconds)'"}' 2>/dev/null

echo "[$(date)] MICO siap. Semua daemon berjalan." >> $LOG
