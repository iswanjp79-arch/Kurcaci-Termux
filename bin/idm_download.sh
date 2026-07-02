#!/bin/bash
# Internet Download Manager — via aria2
echo "=== MICO IDM ==="
echo "Masukkan URL:"
read URL
echo "Mengunduh..."
aria2c -x 16 -s 16 "$URL" -d ~/storage/downloads/
echo "✅ Selesai"
