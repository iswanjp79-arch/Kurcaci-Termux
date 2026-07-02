#!/bin/bash
AUDIT_LOG="$HOME/JDEQ/AUDIT/decisions/audit.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
echo "1. Syntax gateway..." | tee -a "$AUDIT_LOG"
if bash -n ~/JDEQ/mico_gateway.sh 2>/dev/null; then echo "   ✅ Gateway OK" | tee -a "$AUDIT_LOG"; else echo "   ❌ Gateway error" | tee -a "$AUDIT_LOG"; fi
echo "2. Runtime..." | tee -a "$AUDIT_LOG"
pgrep -f llama-server >/dev/null && echo "   ✅ llama-server running" | tee -a "$AUDIT_LOG" || echo "   ❌ llama-server not running" | tee -a "$AUDIT_LOG"
echo "3. Memory..." | tee -a "$AUDIT_LOG"
free -m | grep Mem | awk '{print "   Memory: " $3 "/" $2 " MB"}' | tee -a "$AUDIT_LOG"
echo "4. Audit log..." | tee -a "$AUDIT_LOG"
[ -f "$AUDIT_LOG" ] && echo "   ✅ Audit log exists" | tee -a "$AUDIT_LOG" || echo "   ⚠️ Audit log not found" | tee -a "$AUDIT_LOG"
echo "=============================="
