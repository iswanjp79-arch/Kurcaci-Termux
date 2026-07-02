#!/bin/bash
# Node Health Check
NODES_FILE="$HOME/JDEQ/NODE_REGISTRY/nodes.json"
for NODE in $(jq -r '.nodes[].id' "$NODES_FILE"); do
  STATUS=$(jq -r ".nodes[] | select(.id==\"$NODE\") | .status" "$NODES_FILE")
  if [ "$STATUS" = "active" ]; then
    echo "✅ $NODE active"
  else
    echo "⚠️ $NODE status: $STATUS"
  fi
done
