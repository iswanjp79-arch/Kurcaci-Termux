#!/data/data/com.termux/files/usr/bin/bash
# MICO Gemini CLI Wrapper
VAULT="$HOME/JDEQ/vault/gemini_tokens.json"
TOKEN=$(python3 -c "import json; d=json.load(open('$VAULT')); print(d['tokens'][d['active_token_index']])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ Token Gemini tidak ditemukan"
  exit 1
fi

PROMPT="$*"
if [ -z "$PROMPT" ]; then
  echo "Pakai: gemini_cli.sh <pertanyaan>"
  exit 1
fi

echo "🤖 Gemini CLI: menganalisis..."
python3 -c "
import google.generativeai as genai
genai.configure(api_key='$TOKEN')
model = genai.GenerativeModel('gemini-1.5-flash')
response = model.generate_content('$PROMPT')
print(response.text)
" 2>/dev/null || echo "⚠️ Gemini CLI gagal — cek koneksi internet"
