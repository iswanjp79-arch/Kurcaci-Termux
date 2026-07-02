#!/data/data/com.termux/files/usr/bin/bash
echo "📊 MICO GATEWAY MONITOR"
echo "========================"
echo ""

# Vivo Y28
RAM=$(free -m | grep Mem | awk '{print $4}')
echo "📱 Vivo Y28     : RAM ${RAM} MB"
for proc in llama-server ghost_relay.py mosquitto; do
    if pgrep -f "$proc" > /dev/null; then
        echo "  ✅ $proc"
    else
        echo "  ❌ $proc"
    fi
done

# Infinix
if curl -s --max-time 5 "http://100.103.39.81:8000/health" > /dev/null 2>&1; then
    echo "📱 Infinix       : ✅ ONLINE"
else
    echo "📱 Infinix       : ❌ OFFLINE"
fi

# Colab
if [ -f ~/JDEQ/bridge/ngrok_url.txt ]; then
    URL=$(cat ~/JDEQ/bridge/ngrok_url.txt)
    if curl -s --max-time 5 "${URL}/health" > /dev/null 2>&1; then
        echo "☁️  Colab        : ✅ ONLINE"
    else
        echo "☁️  Colab        : ❌ OFFLINE"
    fi
else
    echo "☁️  Colab        : ⏳ BELUM DIATUR"
fi

echo ""
echo "🌐 Dashboard: http://localhost:8083"
echo "🧠 AI Lokal : http://localhost:8082"
