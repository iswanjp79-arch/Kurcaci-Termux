#!/bin/bash
echo "=== MICO SYSTEM CARE ==="
echo "Membersihkan cache..."
rm -rf ~/.cache/* 2>/dev/null
pkg clean 2>/dev/null
npm cache clean --force 2>/dev/null
echo "Optimasi SQLite..."
sqlite3 ~/JDEQ/RUNTIME/metadata.db "VACUUM;" 2>/dev/null
echo "Membersihkan file sampah..."
find ~/JDEQ -name "*.pyc" -delete 2>/dev/null
echo "✅ System Care selesai"
df -h /data/data/com.termux/files/home | tail -1
