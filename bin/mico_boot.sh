#!/bin/bash
echo "╔══════════════════════════════════════════╗"
echo "║  MICO-JDEQ V7 — SYSTEM BOOT             ║"
echo "╚══════════════════════════════════════════╝"

PASS=0; FAIL=0

check() {
    if eval "$1" 2>/dev/null; then
        echo "   ✅ $2"
        ((PASS++))
    else
        echo "   ❌ $2"
        ((FAIL++))
    fi
}

echo ""
echo "=== STRUKTUR FOLDER ==="
for DIR in SSOT GOVERNANCE MEMORY AUDIT AGENTS CORE KERNEL; do
    check "[ -d ~/JDEQ/$DIR ]" "$DIR"
done

echo ""
echo "=== STATUS SSOT ==="
check "[ -f ~/JDEQ/SSOT/EVENT_TYPES.json ]" "SSOT utuh"

echo ""
echo "=== MODUL AKTIF ==="
check "pgrep -f kernel.py >/dev/null" "Kernel"
check "pgrep -f pocketpal_node >/dev/null" "Bridge"
check "pgrep -f mosquitto >/dev/null" "MQTT"

echo ""
echo "=== KONEKSI ==="
check "ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1" "Internet"
check "pgrep -f sshd >/dev/null" "SSH"

echo ""
echo "=== KESEHATAN ==="
echo "   RAM: $(free -m | awk '/Mem/{print $7}') MB"
echo "   Proses: $(ps aux | wc -l)"
echo ""
echo "SKOR: $PASS/$((PASS+FAIL))"
bash ~/JDEQ/bin/pengendali_terpadu.sh
