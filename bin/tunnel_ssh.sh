#!/data/data/com.termux/files/usr/bin/bash
# JDEQ - SSH Tunnel via Tailscale

set -euo pipefail
source ~/JDEQ/config/tunnel.conf
LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/tunnel_ssh.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Cek Tailscale
if command -v tailscale &> /dev/null; then
    if tailscale status --json | grep -q '"Online":true'; then
        log "✅ Tailscale aktif"
    else
        log "⚠️ Tailscale offline. Jalankan 'tailscale up' dulu."
        exit 1
    fi
else
    log "⚠️ Tailscale tidak terinstall. Lewati."
fi

# Cek SSH
if ! command -v ssh &> /dev/null; then
    log "❌ SSH tidak ditemukan. Install: pkg install openssh"
    exit 1
fi

# Pastikan kunci ada
SSH_KEY_PATH="${SSH_KEY/#\~/$HOME}"
if [ ! -f "$SSH_KEY_PATH" ]; then
    log "❌ Kunci SSH tidak ditemukan di $SSH_KEY_PATH. Buat dulu: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''"
    exit 1
fi

log "🔓 Membuka SSH tunnel ke $REMOTE_USER@$REMOTE_HOST:$REMOTE_PORT"
ssh -f -N -L $LOCAL_PORT:localhost:$REMOTE_PORT -i "$SSH_KEY_PATH" $REMOTE_USER@$REMOTE_HOST
SSH_PID=$!
sleep 2
if kill -0 $SSH_PID 2>/dev/null; then
    log "✅ Tunnel berjalan (PID: $SSH_PID) — lokal:$LOCAL_PORT → remote:$REMOTE_PORT"
else
    log "❌ Tunnel gagal. Cek kredensial atau koneksi."
    exit 1
fi

echo "Tunnel aktif. Tekan ENTER untuk menutup..."
read -r
kill $SSH_PID
log "🔒 Tunnel ditutup."
