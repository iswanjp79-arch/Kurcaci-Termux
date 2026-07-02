#!/data/data/com.termux/files/usr/bin/bash
while true; do
    if ! curl -s http://localhost:8082/v1/chat/completions -d '{"model":"Qwen2.5-3B-Instruct-Q4_K_M.gguf","prompt":"ping","stream":false}' | grep -q '"response"'; then
        echo "$(date) - Ollama tidak siap, restart..." >> ~/JDEQ/logs/ollama_watchdog.log
        pkill -f ollama 2>/dev/null
        sleep 5
        ollama serve &
    fi
    sleep 60
done
