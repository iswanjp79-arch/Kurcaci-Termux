#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# MICO IGNITER — Pemicu Lokal (default) + Cloud (fallback)
# ============================================================

SIGNAL_FILE="$HOME/JDEQ/.signal_ignite"
SIGNAL_URL="https://gist.githubusercontent.com/raw/sinyal_mico.txt"
LOG="$HOME/JDEQ/log/igniter.log"

mkdir -p "$(dirname "$LOG")"

# Fungsi menyalakan MICO
ignite() {
    echo "$(date): 🔥 Menyalakan MICO..." | tee -a "$LOG"
    
    # Matikan wake lock dulu biar restart bersih
    termux-wake-lock release 2>/dev/null
    sleep 1
    
    # Jalankan supervisor jika belum hidup
    if ! pgrep -f supervisor_daemon.py > /dev/null; then
        nohup python3 ~/JDEQ/MICO_LIFECYCLE/supervisor_daemon.py > /dev/null 2>&1 &
        echo "   ✅ Supervisor menyala" | tee -a "$LOG"
    else
        echo "   ⏩ Supervisor sudah hidup" | tee -a "$LOG"
    fi
    
    # Jalankan llama-server jika belum
    if ! pgrep -f llama-server > /dev/null; then
        nohup llama-server -m ~/models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf \
            --host 127.0.0.1 --port 8082 -c 256 -t 1 --no-warmup -ngl 0 > /dev/null 2>&1 &
        echo "   ✅ LLM menyala" | tee -a "$LOG"
    else
        echo "   ⏩ LLM sudah hidup" | tee -a "$LOG"
    fi
    
    # Amankan dengan wake lock
    termux-wake-lock acquire 2>/dev/null
    echo "   🔥 MICO SIAP." | tee -a "$LOG"
}

# Fungsi memadamkan MICO
stop_mico() {
    echo "$(date): 🧯 Memadamkan MICO..." | tee -a "$LOG"
    pkill -f supervisor_daemon.py 2>/dev/null
    pkill -f llama-server 2>/dev/null
    termux-wake-lock release 2>/dev/null
    echo "   ✅ MICO padam." | tee -a "$LOG"
}

# ========== CEK PEMICU ==========

# 1. Cek file lokal (prioritas, tanpa internet)
if [ -f "$SIGNAL_FILE" ]; then
    SINYAL=$(cat "$SIGNAL_FILE" 2>/dev/null | head -1)
    rm -f "$SIGNAL_FILE"  # Hapus setelah dibaca (sekali pakai)
    
    if [ "$SINYAL" = "IGNITE" ]; then
        ignite
    elif [ "$SINYAL" = "STOP" ]; then
        stop_mico
    fi
fi

# 2. Cek cloud (fallback, timeout 5 detik untuk koneksi lambat)
if [ -n "$SIGNAL_URL" ]; then
    SINYAL_CLOUD=$(curl -s --max-time 5 "$SIGNAL_URL" 2>/dev/null | head -1)
    if [ "$SINYAL_CLOUD" = "IGNITE" ]; then
        ignite
    elif [ "$SINYAL_CLOUD" = "STOP" ]; then
        stop_mico
    fi
fi
