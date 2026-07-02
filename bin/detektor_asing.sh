#!/bin/bash
IZIN_IP="100.123.232.84 100.103.39.81"
IP_MASUK="$1"
if echo "$IZIN_IP" | grep -q "$IP_MASUK"; then
  echo "✅ DITERIMA"
else
  echo "⛔ DITOLAK: $IP_MASUK"
  ~/JDEQ/bin/send_telegram.sh "🚨 PERCOBAAN AKSES ASING: $IP_MASUK"
  exit 1
fi
