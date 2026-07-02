#!/bin/bash
INPUT="$*"
if [ -z "$INPUT" ]; then echo "Tidak ada input."; exit 1; fi
source ~/JDEQ/bin/load_api_keys.sh 2>/dev/null
if [ -n "$OPENROUTER_KEY_02" ]; then
  curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" -H "Authorization: Bearer $OPENROUTER_KEY_02" -H "Content-Type: application/json" -d "{\"model\":\"openai/gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"$INPUT\"}],\"max_tokens\":100}" 2>/dev/null | jq -r '.choices[0].message.content // "Tidak ada respons"'
else
  echo "⚠️ OPENROUTER_KEY_02 tidak ditemukan, fallback ke Qwen"
  curl -s -X POST http://127.0.0.1:8082/completion -H "Content-Type: application/json" -d "{\"prompt\":\"$INPUT\",\"n_predict\":30}" | jq -r '.content // "Tidak ada respons"'
fi
