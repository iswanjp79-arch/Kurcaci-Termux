#!/data/data/com.termux/files/usr/bin/bash
# MICO Multi-Device Orchestrator
LOG=~/JDEQ/logs/multi_device.log

echo "$(date): Multi-Device Check" >> "$LOG"

# Daftar perangkat terdaftar
echo "  📱 Vivo Y28     : Master (Router + MICO)"
echo "  📱 Infinix      : Server AI Lokal (Tailscale)"
echo "  ☁️  Colab        : Cloud Worker (Ngrok)"
echo "  💻 Travelmate   : OFFLINE (rusak)"

# Cek Infinix (via Tailscale)
if curl -s --max-time 5 "http://ananda-madina-riswan.tail2a1291.ts.net:8000/health" > /dev/null 2>&1; then
    echo "  ✅ Infinix ONLINE"
else
    echo "  ⚠️  Infinix OFFLINE"
fi

# Cek Colab (via ngrok)
if [ -f ~/JDEQ/bridge/ngrok_url.txt ]; then
    URL=$(cat ~/JDEQ/bridge/ngrok_url.txt)
    if curl -s --max-time 5 "${URL}/health" > /dev/null 2>&1; then
        echo "  ✅ Colab ONLINE"
    else
        echo "  ⚠️  Colab OFFLINE"
    fi
fi

echo "  🟢 MICO Router: AKTIF (port 8086)"
echo "" >> "$LOG"
