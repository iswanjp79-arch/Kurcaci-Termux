#!/data/data/com.termux/files/usr/bin/bash
# Healer real-time: cek & restart mosquitto jika mati
if ! pgrep mosquitto > /dev/null; then
    echo "$(date): mosquitto mati. Menghidupkan..." >> ~/JDEQ/logs/healer.log
    mosquitto -c ~/JDEQ/config/mosquitto.conf -d
    echo "$(date): mosquitto dihidupkan oleh process_healer." >> ~/JDEQ/logs/healer.log
fi
