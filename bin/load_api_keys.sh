#!/bin/bash
if [ -f ~/JDEQ/VAULT/keys/api_keys.env ]; then
  set -a
  source ~/JDEQ/VAULT/keys/api_keys.env
  set +a
  echo "✅ API Keys loaded"
else
  echo "⚠️ API Keys not found"
fi
