#!/bin/bash
# Audit Engine – catat keputusan dan trace
AUDIT_DIR="$HOME/JDEQ/AUDIT"
ACTION="$1"
DETAIL="$2"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] $ACTION: $DETAIL" >> "$AUDIT_DIR/decisions/audit.log"
echo "[$TIMESTAMP] $ACTION" >> "$AUDIT_DIR/traces/trace.log"
