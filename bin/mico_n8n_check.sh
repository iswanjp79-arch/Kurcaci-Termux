#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
if command -v n8n > /dev/null 2>&1; then
  log "INFO" "N8N CLI installed"
  # Check if n8n process is running
  pgrep -f "n8n start" > /dev/null && { log "INFO" "N8N running"; exit 0; }
  log "WARN" "N8N installed but not running"
  exit 2
fi
# Check Python Orchestrator as fallback
pgrep -f unified_orchestrator.py > /dev/null && { log "INFO" "Python Orchestrator active (N8N replacement)"; exit 0; }
log "WARN" "N8N not installed, Orchestrator not active"
exit 2
