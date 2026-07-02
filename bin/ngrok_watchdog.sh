#!/data/data/com.termux/files/usr/bin/bash
while true; do
  if ! pgrep -f "ngrok http 9090" > /dev/null; then
    echo "[$(date)] Ngrok mati, menyalakan ulang..." >> ~/ngrok_watchdog.log
    ngrok http 9090 --log=stdout > ~/ngrok.log 2>&1 &
    sleep 5
  fi
  sleep 10
done
