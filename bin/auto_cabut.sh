#!/bin/bash
BATAS_MENIT=10
while true; do
  for IP in "100.103.39.81"; do
    if ! ping -c 1 -W 3 "$IP" > /dev/null 2>&1; then
      LAST_SEEN=$(cat ~/JDEQ/AUDIT/last_seen_$IP 2>/dev/null || echo 0)
      NOW=$(date +%s)
      DIFF=$(( (NOW - LAST_SEEN) / 60 ))
      if [ "$DIFF" -gt "$BATAS_MENIT" ]; then
        echo "[$(date)] ⛔ $IP offline ${DIFF} menit — MENCABUT AKSES"
        ~/JDEQ/bin/send_telegram.sh "🚨 $IP offline ${DIFF} menit. Akses DICABUT."
        echo "[$(date)] $IP AKSES_DICABUT" >> ~/JDEQ/AUDIT/cabut_akses.log
      fi
    else
      date +%s > ~/JDEQ/AUDIT/last_seen_$IP
    fi
  done
  sleep 60
done
