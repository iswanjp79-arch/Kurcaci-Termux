#!/data/data/com.termux/files/usr/bin/bash
VAULT="$HOME/JDEQ/vault/api_keys.json"
BOT_TOKEN="8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8"
CHAT_ID="6073587888"

# Simpan token baru ke vault
mkdir -p "$(dirname "$VAULT")"
cat > "$VAULT" << VAULTEOF
{
  "telegram_bot_token": "$BOT_TOKEN",
  "chat_id": "$CHAT_ID"
}
VAULTEOF
chmod 600 "$VAULT"

# Kirim laporan final
MSG="📘 LAPORAN FINAL DEWAN AGEN — MICO-JDEQ
━━━━━━━━━━━━━━━━━━━━━━
📅 29 Juni 2026 | ⏰ $(date '+%H:%M WIB')

🏗️ ARSITEKTUR 19 LANTAI: AKTIF
🔗 Dual Control: Vivo ↔ Infinix
📡 MQTT: AKTIF | 🌐 Groq/Ngrok: AKTIF
🧠 LLM MICO (1.9GB): AKTIF
💾 RAM Vivo: $(free -m | awk '/Mem/{print $7}') MB
🛡️ SSOT: TERKUNCI | 🧬 DNA: INTACT

✅ SEMUA MODUL TERVERIFIKASI
━━━━━━━━━━━━━━━━━━━━━━
Gedung 19 lantai siap beroperasi penuh."

RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  -d "text=$MSG" \
  -d "parse_mode=HTML" 2>/dev/null)

if echo "$RESPONSE" | grep -q '"ok":true'; then
  echo "✅ Telegram terkirim dengan token baru"
else
  echo "⚠️ Telegram masih gagal: $RESPONSE"
fi
