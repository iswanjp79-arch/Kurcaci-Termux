#!/data/data/com.termux/files/usr/bin/bash
# ===================================================
# LOCK KONEKSI PERMANEN - VIVO Y28 ↔ INFINIX
# Mode: ONLINE | OFFLINE | MIDDLE
# ===================================================

IP="100.103.39.81"
PORT="8000"
ENDPOINT="http://$IP:$PORT/v1/chat/completions"
HEALTH="http://$IP:$PORT/health"
URL_FILE="$HOME/JDEQ/bridge/ngrok_url.txt"
CACHE_DIR="$HOME/JDEQ/cache"
LOG="$HOME/JDEQ/logs/lock_connection.log"
MIDDLE_MODE="$HOME/JDEQ/cache/middle_mode.flag"

mkdir -p $CACHE_DIR
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

# ============================
# MODE 1: ONLINE - KONEKSI PENUH
# ============================
mode_online() {
    stamp "🌐 MODE ONLINE — Koneksi penuh"
    
    # Update endpoint
    echo "$ENDPOINT" > $URL_FILE
    
    # Restart Ghost Relay
    pkill -f ghost_relay.py 2>/dev/null
    sleep 1
    nohup python3 ~/JDEQ/bridge/ghost_relay.py > /dev/null 2>&1 &
    sleep 2
    
    # Verifikasi
    if curl -s --max-time 3 "$HEALTH" > /dev/null 2>&1; then
        stamp "✅ Infinix ONLINE — MICO otak penuh"
        rm -f $MIDDLE_MODE
        return 0
    else
        stamp "⚠️ Gagal online — coba mode middle"
        return 1
    fi
}

# ============================
# MODE 2: OFFLINE - MANDIRI LOKAL
# ============================
mode_offline() {
    stamp "📴 MODE OFFLINE — MICO mandiri lokal"
    
    # Hentikan Ghost Relay (tidak perlu)
    pkill -f ghost_relay.py 2>/dev/null
    
    # Cek ketersediaan lokal
    if curl -s --max-time 2 http://localhost:8082/v1/models > /dev/null 2>&1; then
        stamp "✅ LLM lokal siap — MICO tetap berfungsi"
    else
        stamp "⚠️ LLM lokal juga mati — hanya kalkulasi dasar"
    fi
    
    # Simpan perintah ke cache untuk dikirim nanti
    touch $CACHE_DIR/offline_queue.txt
    stamp "📝 Perintah akan dicatat di cache"
}

# ============================
# MODE 3: MIDDLE - JEMBATAN CERDAS
# ============================
mode_middle() {
    stamp "🌓 MODE MIDDLE — Jembatan adaptif"
    touch $MIDDLE_MODE
    
    # Coba online dulu
    if mode_online; then
        # Kirim antrian offline jika ada
        if [ -s $CACHE_DIR/offline_queue.txt ]; then
            stamp "📤 Mengirim antrian offline..."
            cat $CACHE_DIR/offline_queue.txt >> $LOG
            > $CACHE_DIR/offline_queue.txt
        fi
        return 0
    fi
    
    # Jika gagal, pakai cache dan respons lokal
    stamp "🔄 Jaringan tidak stabil — pakai cache + lokal"
    
    # Cek MQTT sebagai alternatif
    if pgrep mosquitto > /dev/null; then
        stamp "📡 MQTT siap sebagai jalur alternatif"
    fi
    
    return 0
}

# ============================
# EKSEKUSI OTOMATIS
# ============================
stamp "==================== LOCK KONEKSI ===================="

# Tes dasar: ping
if ping -c 1 -W 1 $IP > /dev/null 2>&1; then
    # Jaringan hidup → coba online
    if ! mode_online; then
        # Online gagal → middle
        mode_middle
    fi
else
    # Jaringan mati → offline
    mode_offline
fi

# Pastikan endpoint selalu terbarui
echo "$ENDPOINT" > $URL_FILE

stamp "======================================================"
