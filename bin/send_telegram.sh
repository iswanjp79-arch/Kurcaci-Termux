#!/bin/bash
# ============================================================
# ✅ VERSI IDEAL MICO‑JDEQ V7 — TANPA PENGULANGAN · TOKEN BARU
# Aturan: Hanya kirim jika berbeda; gagal = catat saja
# ============================================================
TOKEN="8052456691:AAHCaHomQBTveuSwRje0DAWTxjGXMS6ZaKU"
CHAT_ID="8702459215"
PESAN_KIRIM="$1"
BERKAS_PENYIMPAN=~/JDEQ/AUDIT/kiriman_terakhir.txt
BERKAS_CATATAN_GAGAL=~/JDEQ/AUDIT/telegram_gagal.log

mkdir -p ~/JDEQ/AUDIT
PESAN_TERAKHIR=$(cat "$BERKAS_PENYIMPAN" 2>/dev/null || echo "===TANDA AWAL SISTEM===")

if [ "$PESAN_KIRIM" != "$PESAN_TERAKHIR" ] && [ -n "$PESAN_KIRIM" ]; then
    HASIL_KIRIM=$(curl -s -w "%{http_code}" -o /dev/null \
      -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
      -d "chat_id=$CHAT_ID" -d "text=$PESAN_KIRIM" 2>/dev/null)

    if [ "$HASIL_KIRIM" = "200" ]; then
        echo "$PESAN_KIRIM" > "$BERKAS_PENYIMPAN"
        echo "✅ [TELEGRAM] Terkirim: ${PESAN_KIRIM:0:40}..."
    else
        echo "[$(date +%Y%m%d_%H%M%S)] Gagal kode:$HASIL_KIRIM -> $PESAN_KIRIM" >> "$BERKAS_CATATAN_GAGAL"
        echo "⚠️ [TELEGRAM] Gagal kirim — dicatat ke berkas"
    fi
else
    echo "🔇 [TELEGRAM] Pesan sama/kosong — diabaikan"
fi
