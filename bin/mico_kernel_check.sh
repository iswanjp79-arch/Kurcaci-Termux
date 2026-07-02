#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
if [ -d ~/JDEQ/KERNEL ] && [ -f ~/JDEQ/KERNEL/decision_kernel.py ]; then
  PERM=$(stat -c "%a" ~/JDEQ/CONSTITUTION 2>/dev/null)
  [ "$PERM" = "700" ] && { log "INFO" "Kernel OK"; exit 0; }
  log "WARN" "Kernel permission $PERM"; exit 2
fi
log "ERROR" "Kernel missing"; exit 1
