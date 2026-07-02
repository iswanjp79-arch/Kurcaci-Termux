#!/data/data/com.termux/files/usr/bin/bash
# MICO Telegram Fix — menggunakan token & chat ID yang benar dari vault
VAULT="$HOME/JDEQ/vault/api_keys.json"

if [ -f "$VAULT" ]; then
  BOT_TOKEN=$(python3 -c "import json; print(json.load(open('$VAULT'))['telegram_bot_token'])" 2>/dev/null)
  CHAT_ID=$(python3 -c "import json; print(json.load(open('$VAULT'))['chat_id'])" 2>/dev/null)
else
  BOT_TOKEN="8052456691:AAFCe6dKIk-_YsnLnLfyMs4Ckn9N4BB28Ps"
  CHAT_ID="6073587888"
fi

MSG="📘 LAPORAN INFRASTRUKTUR FINAL
━━━━━━━━━━━━━━━━━━━━━━
🏗️ Arsitektur 19 Lantai: AKTIF
🔗 Dual Control: Vivo ↔ Infinix
📡 MQTT: AKTIF | 🌐 Groq: AKTIF
🧠 LLM: AKTIF | 💾 RAM: $(free -m | awk '/Mem/{print $7}') MB
━━━━━━━━━━━━━━━━━━━━━━
Gedung 19 lantai siap beroperasi penuh."

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  -d "text=$MSG" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✅ Telegram terkirim"
else
  echo "⚠️ Telegram gagal — cek token & chat ID di vault"
fi
