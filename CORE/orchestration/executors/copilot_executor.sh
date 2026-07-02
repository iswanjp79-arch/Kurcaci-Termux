#!/bin/bash
INPUT="$*"
source ~/JDEQ/bin/load_api_keys.sh 2>/dev/null
echo "🔶 Copilot executor – GitHub token: $GITHUB_TOKEN"
curl -s -X POST http://127.0.0.1:8082/completion -H "Content-Type: application/json" -d "{\"prompt\":\"$INPUT\",\"n_predict\":30}" | jq -r '.content // "Tidak ada respons"'
