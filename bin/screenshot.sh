#!/bin/bash
echo "=== MICO SCREENSHOT ==="
if command -v termux-screenshot &>/dev/null; then
    termux-screenshot ~/storage/downloads/screenshot_$(date +%Y%m%d_%H%M%S).png
    echo "✅ Screenshot tersimpan di ~/storage/downloads/"
else
    echo "⚠️  termux-screenshot tidak tersedia"
fi
