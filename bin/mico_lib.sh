#!/bin/bash
# MICO-JDEQ Production Library v1.0
CFG="$HOME/JDEQ/bin/mico_config.env"
[ -f "$CFG" ] && source "$CFG"

MICO_TELEGRAM_TOKEN="${MICO_TELEGRAM_TOKEN:-8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8}"
MICO_TELEGRAM_CHAT_ID="${MICO_TELEGRAM_CHAT_ID:-8702459215}"
MICO_LOG_DIR="${MICO_LOG_DIR:-$HOME/JDEQ/logs}"
MICO_SSOT_DIR="${MICO_SSOT_DIR:-$HOME/JDEQ/SSOT}"
MICO_BACKUP_DIR="${MICO_BACKUP_DIR:-$HOME/JDEQ/backup}"
MICO_INFINIX_IP="${MICO_INFINIX_IP:-100.103.39.81}"
MICO_ORCHESTRATOR_PID=$(pgrep -f unified_orchestrator.py 2>/dev/null)

mkdir -p "$MICO_LOG_DIR" "$MICO_BACKUP_DIR"

PASS=0; FAIL=0; WARN=0

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> "$MICO_LOG_DIR/mico.log"; }
notify() { curl -s -X POST "https://api.telegram.org/bot${MICO_TELEGRAM_TOKEN}/sendMessage" -d "chat_id=${MICO_TELEGRAM_CHAT_ID}" -d "text=$1" > /dev/null 2>&1; }
