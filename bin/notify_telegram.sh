#!/data/data/com.termux/files/usr/bin/bash
TOKEN="8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8"
CHAT_ID="8702459215"
MSG="$1"
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  -d "text=$MSG"
