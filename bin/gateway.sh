#!/bin/bash
# JDEQ L4 Readiness Gateway - Vivo Y28 spesifik
MODEL_LOADED=0
MAX_RETRIES=10
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
  RESP=$(curl -s http://127.0.0.1:8082/health)
  if echo "$RESP" | grep -q '"status":"ok"'; then
    MODEL_LOADED=1
    break
  else
    echo "[*] Nunggu model loading... retry $((RETRY+1))/$MAX_RETRIES"
    sleep 3
    RETRY=$((RETRY+1))
  fi
done
if [ $MODEL_LOADED -eq 1 ]; then
  python ~/JDEQ/mico_chat.py --cmd "$*"
else
  echo "ERROR: Model gagal loading sawise $MAX_RETRIES kali."
fi
