#!/bin/bash
INPUT="$*"
source ~/JDEQ/bin/load_api_keys.sh 2>/dev/null
if [ -n "$CLAUDE_KEY_01" ]; then
  curl -s -X POST https://api.anthropic.com/v1/messages \
    -H "x-api-key: $CLAUDE_KEY_01" -H "anthropic-version: 2023-06-01" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"claude-3-haiku-20240307\",\"max_tokens\":100,\"messages\":[{\"role\":\"user\",\"content\":\"$INPUT\"}]}" | jq -r '.content[0].text // "Tidak ada respons"'
else
  curl -s -X POST http://127.0.0.1:8082/completion -H "Content-Type: application/json" -d "{\"prompt\":\"$INPUT\",\"n_predict\":30}" | jq -r '.content // "Tidak ada respons"'
fi
