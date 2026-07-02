#!/bin/bash
# Scheduler Orchestrator – membaca workflow + PEP
WORKFLOW="$HOME/JDEQ/PROJECT_CONTROL/WORKFLOW/workflow.json"
PEP="$HOME/JDEQ/PROJECT_CONTROL/PEP/action_plan.json"
echo "[SCHEDULER] Memeriksa workflow dan PEP..."
if [ -f "$WORKFLOW" ] && [ -f "$PEP" ]; then
  echo "[SCHEDULER] Workflow dan PEP ditemukan"
  echo "[SCHEDULER] Tahap aktif: $(jq -r '.stages[] | select(.status=="READY") | .name' "$WORKFLOW" | head -1)"
else
  echo "[SCHEDULER] Workflow atau PEP tidak ditemukan"
fi
