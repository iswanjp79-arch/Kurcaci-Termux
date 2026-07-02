#!/bin/bash
echo "🔄 MEMULIHKAN MICO DARI CADANGAN VIVO..."
mkdir -p ~/JDEQ
cp -r ./* ~/JDEQ/
chmod +x ~/JDEQ/bin/*.sh 2>/dev/null
bash ~/JDEQ/bin/mico_boot.sh
echo "✅ PEMULIHAN SELESAI — MICO HIDUP KEMBALI"
