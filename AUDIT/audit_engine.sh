#!/bin/bash
AUDIT_DIR="$HOME/JDEQ/AUDIT"
ACTION="$1"
DETAIL="$2"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
mkdir -p "$AUDIT_DIR/LOGS" "$AUDIT_DIR/DECISIONS" "$AUDIT_DIR/TRACES" "$AUDIT_DIR/REPORTS"
echo "[$TIMESTAMP] $ACTION: $DETAIL" >> "$AUDIT_DIR/DECISIONS/audit.log"
echo "[$TIMESTAMP] $ACTION" >> "$AUDIT_DIR/TRACES/trace.log"
TOTAL=$(wc -l < "$AUDIT_DIR/DECISIONS/audit.log")
if [ $((TOTAL % 10)) -eq 0 ]; then
  echo "[$TIMESTAMP] Ringkasan $TOTAL entri" >> "$AUDIT_DIR/REPORTS/summary.log"
fi
