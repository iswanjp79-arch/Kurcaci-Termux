#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
echo "========================================"
echo " MICO-JDEQ DASHBOARD"
echo "========================================"
echo " Kernel      : $([ -f ~/JDEQ/KERNEL/decision_kernel.py ] && echo OK || echo FAIL)"
echo " SSOT        : $([ -f ~/JDEQ/SSOT/EVENT_TYPES.json ] && echo OK || echo FAIL)"
echo " Orchestrator: $([ -n "$MICO_ORCHESTRATOR_PID" ] && echo "PID $MICO_ORCHESTRATOR_PID" || echo DEAD)"
echo " Healer      : $(crontab -l 2>/dev/null | grep -q mico_healer && echo CRON || echo MANUAL)"
echo " RAM         : $(free -m | awk '/Mem/{print $4}') MB"
echo " Storage     : $(df -h /data | tail -1 | awk '{print $4}')"
echo "========================================"
exit 0
