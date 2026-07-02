#!/data/data/com.termux/files/usr/bin/bash
# JDEQ RECOVERY – VERSI FINAL (TANPA ERROR FI)

set -e
cd ~/JDEQ || exit

LOG_FILE="logs/recovery_$(date +%Y%m%d_%H%M%S).log"
MODEL_PATH="/storage/emulated/0/AI_Models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "  JDEQ RECOVERY – AUTO PERBAIKI DIRI"
echo "=========================================="
echo "Log: $LOG_FILE"

# Cek RAM
echo ""
echo "[1/6] Cek RAM..."
free -h

# Matikan proses lama
echo ""
echo "[2/6] Matikan llama-server lama..."
pkill -f llama-server 2>/dev/null && echo "✅ Mati" || echo "ℹ️ Tidak ada"

# Start server dengan ctx 256 (stabil)
echo ""
echo "[3/6] Start server (ctx=256, thread=1)..."
nohup llama-server -m "$MODEL_PATH" \
  --host 0.0.0.0 --port 8082 \
  --ctx-size 256 -ngl 0 -t 1 \
  > logs/mico_server_256.log 2>&1 &

sleep 5

# Cek status server
echo ""
echo "[4/6] Cek status server..."
if pgrep -f llama-server > /dev/null; then
    echo "✅ Server berjalan (PID: $(pgrep -f llama-server | head -1))"
else
    echo "❌ Server gagal start. Cek log: tail logs/mico_server_256.log"
    tail -10 logs/mico_server_256.log
    exit 1
fi

# Uji health
echo ""
echo "[5/6] Uji health..."
HEALTH=$(curl -s http://127.0.0.1:8082/health 2>/dev/null || echo "GAGAL")
if echo "$HEALTH" | grep -q '"status":"ok"'; then
    echo "✅ Health OK: $HEALTH"
else
    echo "⚠️ Health response: $HEALTH"
fi

# Uji inference langsung (tanpa Python)
echo ""
echo "[6/6] Uji inference (curl langsung)..."
RESPONSE=$(curl -s -X POST http://localhost:8082/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"halo"}],"max_tokens":16}' \
  --max-time 10 2>/dev/null || echo "GAGAL")

if echo "$RESPONSE" | grep -q '"content"'; then
    echo "✅ QWEN MERESPON:"
    echo "$RESPONSE" | head -5
    echo ""
    echo "=== STATUS: QWEN SEHAT & BERJALAN ==="
else
    echo "❌ QWEN TIDAK MERESPON (atau timeout)"
    echo "   Detail: $RESPONSE" | head -5
    echo ""
    echo "=== STATUS: QWEN PERLU DIPERIKSA LEBIH LANJUT ==="
    echo "   Cek log server: tail -20 logs/mico_server_256.log"
fi

echo ""
echo "✅ RECOVERY SELESAI. Log tersimpan di: $LOG_FILE"
echo "=========================================="
