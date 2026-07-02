#!/bin/bash
INPUT="$*"
if [ -z "$INPUT" ]; then echo "Tidak ada input."; exit 1; fi

# Baca daftar kunci
KEYS_FILE="$HOME/.daftar_kunci.txt"
if [ ! -f "$KEYS_FILE" ]; then
  echo "⚠️ File kunci tidak ditemukan"
  curl -s -X POST http://127.0.0.1:8082/completion -H "Content-Type: application/json" -d "{\"prompt\":\"$INPUT\",\"n_predict\":30}" | jq -r '.content // "Tidak ada respons"'
  exit 0
fi

# Loop melalui semua kunci
while IFS= read -r key; do
  if [ -z "$key" ]; then continue; fi
  # Ambil string setelah "KUNCI_NOMER_X_" jika ada
  clean_key=$(echo "$key" | sed 's/^KUNCI_NOMER_[0-9]*_//')
  if [[ "$clean_key" != AIzaSy* ]]; then continue; fi
  
  RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$clean_key" \
    -H "Content-Type: application/json" \
    -d "{\"contents\":[{\"parts\":[{\"text\":\"$INPUT\"}]}]}" 2>/dev/null)
  
  if echo "$RESPONSE" | grep -q "error"; then
    echo "⚠️ Kunci gagal, mencoba kunci lain..." >&2
    continue
  else
    echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // "Tidak ada respons"'
    exit 0
  fi
done < "$KEYS_FILE"

# Jika semua kunci gagal, fallback ke Qwen
echo "⚠️ Semua kunci gagal, fallback ke Qwen"
curl -s -X POST http://127.0.0.1:8082/completion -H "Content-Type: application/json" -d "{\"prompt\":\"$INPUT\",\"n_predict\":30}" | jq -r '.content // "Tidak ada respons"'
