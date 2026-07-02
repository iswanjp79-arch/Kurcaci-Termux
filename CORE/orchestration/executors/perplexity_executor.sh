#!/bin/bash
# Perplexity Executor – Fallback ke Qwen jika API key tidak ada

INPUT="$*"
if [ -z "$INPUT" ]; then
  echo "Tidak ada input."
  exit 1
fi

# Simpan log
echo "[PERPLEXITY] Menerima: $INPUT" >> ~/JDEQ/log/perplexity.log

# Jika API key tidak ada, gunakan Qwen lokal
if [ -z "$PERPLEXITY_API_KEY" ]; then
  echo "⚠️ PERPLEXITY_API_KEY belum diset, menggunakan Qwen lokal sebagai fallback." >> ~/JDEQ/log/perplexity.log
  # Panggil Qwen lokal dengan n_predict=30 (lebih cepat)
  curl -s -X POST http://127.0.0.1:8082/completion \
    -H "Content-Type: application/json" \
    -d "{\"prompt\":\"$INPUT\",\"n_predict\":30}" | jq -r '.content // "Tidak ada respons"'
else
  echo "Belum terintegrasi dengan API Perplexity" >> ~/JDEQ/log/perplexity.log
fi
