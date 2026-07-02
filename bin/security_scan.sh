#!/bin/bash
echo "=== MICO SECURITY SCAN ==="
echo "Memeriksa proses asing..."
ps aux | grep -v "u0_a221" | grep -v "grep" | grep -v "ps aux"
echo ""
echo "Memeriksa port terbuka..."
netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null
echo ""
echo "Memeriksa symlink rusak..."
find ~/JDEQ -xtype l 2>/dev/null | head -5
echo ""
echo "Memeriksa file tanpa izin..."
find ~/JDEQ -type f -perm 777 2>/dev/null | head -5
echo "✅ Security scan selesai"
