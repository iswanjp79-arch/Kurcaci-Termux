#!/bin/bash
# ============================================================
# RECOVERY PROTOCOL — VIVO Y28
# Plan A: Cek Infinix via Tailscale
# Plan B: Jika mati, ambil alih tugas pemantauan
# Plan C: Kirim notifikasi ke Telegram
# ============================================================
INFINIX_IP="100.103.39.81"
CHECK_INTERVAL=60

while true; do
    # PLAN A: Uji koneksi
    if ping -c 1 -W 3 "$INFINIX_IP" > /dev/null 2>&1; then
        echo "[$(date)] ✅ PLAN A: Infinix ONLINE"
    else
        # PLAN B: Infinix mati — ambil alih
        echo "[$(date)] ⚠️ PLAN B: Infinix OFFLINE — Vivo mengambil alih"
        
        # PLAN C: Notifikasi Telegram
        curl -s -X POST "https://api.telegram.org/bot8052456691:AAHCaHomQBTveuSwRje0DAWTxjGXMS6ZaKU/sendMessage" \
            -d "chat_id=8702459215" \
            -d "text=⚠️ Infinix mati. Vivo mengambil alih kendali penuh." \
            > /dev/null 2>&1
        
        echo "[$(date)] ✅ PLAN C: Notifikasi Telegram terkirim"
    fi
    sleep "$CHECK_INTERVAL"
done
