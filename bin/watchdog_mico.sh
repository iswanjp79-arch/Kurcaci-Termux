#!/data/data/com.termux/files/usr/bin/bash
while true; do
  if ! curl -s http://127.0.0.1:8082/props >/dev/null 2>&1; then
    pkill -9 -f llama-server 2>/dev/null
    nohup llama-server -m /storage/emulated/0/AI_Models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf --host 127.0.0.1 --port 8082 --ctx-size 512 -ngl 0 -t 1 --no-warmup > ~/JDEQ/logs/llama.log 2>&1 &
  fi
  sleep 60
done
