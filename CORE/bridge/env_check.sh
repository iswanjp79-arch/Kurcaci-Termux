#!/bin/bash
JDEQ="/data/data/com.termux/files/home/JDEQ"
AUDIT="$JDEQ/CORE_MEMORY/logs/audit.log"
log() { echo "$(date '+%F %T') | BRIDGE | $1 | $2" >> "$AUDIT"; }

echo "[BRIDGE] Mengecek Environment..."
echo "Termux : $( [ -d /data/data/com.termux/files ] && echo 'ONLINE' || echo 'OFFLINE' )"

# Deteksi Nix di beberapa lokasi yang mungkin
NIX_FOUND=""
for path in \
    "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/nix" \
    "/data/data/com.termux/files/home/.nix-profile" \
    "/nix" \
    "$HOME/.nix-profile"; do
    if [ -d "$path" ]; then
        NIX_FOUND="$path"
        break
    fi
done

if [ -n "$NIX_FOUND" ]; then
    echo "Nix    : ONLINE ($NIX_FOUND)"
    nix_status="OK"
else
    echo "Nix    : OFFLINE (lokasi tidak ditemukan)"
    nix_status="FAIL"
fi

echo "Python : $(python3 --version 2>/dev/null || echo 'MISSING')"
log "ENV_CHECK" "Termux=OK Nix=$nix_status"
