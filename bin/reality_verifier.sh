#!/data/data/com.termux/files/usr/bin/bash
# Uji apakah layanan benar-benar berfungsi, bukan hanya hidup
VERIFY_LOG="$HOME/JDEQ/logs/reality_verify.log"

# Uji LLM: kirim prompt kecil
LLM_OK=$(curl -s --max-time 5 http://localhost:8082/v1/chat/completions \
  -d '{"messages":[{"role":"user","content":"1+1"}],"max_tokens":5}' 2>/dev/null | grep -q "choices" && echo "✅" || echo "❌")

# Uji Infinix: kirim perintah ringan
INFINIX_OK=$(curl -s --max-time 5 -X POST http://100.103.39.81:9000 \
  -d '{"cmd":"echo ok"}' 2>/dev/null | grep -q "ok" && echo "✅" || echo "❌")

echo "[$(date)] LLM:$LLM_OK Infinix:$INFINIX_OK" >> $VERIFY_LOG
echo "LLM:$LLM_OK Infinix:$INFINIX_OK"
