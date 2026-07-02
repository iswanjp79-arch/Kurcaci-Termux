#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
BIN="$HOME/JDEQ/bin"

PASS=0; FAIL=0; WARN=0

run_check() {
    local name="$1"
    local script="$2"

    if [ -f "$script" ]; then
        bash "$script" > /dev/null 2>&1
        case $? in
            0) echo "✅ PASS: $name"; PASS=$((PASS+1)) ;;
            1) echo "❌ FAIL: $name"; FAIL=$((FAIL+1)) ;;
            *) echo "⚠️  WARN: $name"; WARN=$((WARN+1)) ;;
        esac
    else
        echo "⚠️  WARN: $name (script not found: $script)"
        WARN=$((WARN+1))
    fi
}

echo "========================================"
echo "MICO-JDEQ FINAL PRODUCTION AUDIT"
echo "========================================"

run_check "Kernel"              "$BIN/mico_kernel_check.sh"
run_check "SSOT"                "$BIN/mico_ssot_check.sh"
run_check "Reference Router"    "$BIN/mico_reference_router_check.sh"
run_check "Orchestrator"        "$BIN/mico_orchestrator_check.sh"
run_check "Healer"              "$BIN/mico_healer_check.sh"
run_check "Cron"                "$BIN/mico_cron_check.sh"
run_check "Telegram"            "$BIN/mico_notify.sh"
run_check "Socket"              "$BIN/mico_socket_test.sh"
run_check "Storage"             "$BIN/mico_storage_check.sh"
run_check "Performance"         "$BIN/mico_performance_check.sh"
run_check "Security"            "$BIN/mico_security_check.sh"
run_check "AI"                  "$BIN/mico_ai_check.sh"
run_check "Cloud"               "$BIN/mico_cloud_check.sh"
run_check "N8N"                 "$BIN/mico_n8n_check.sh"
run_check "Backup"              "$BIN/mico_backup.sh"
run_check "Restore"             "$BIN/mico_restore.sh"
run_check "Dashboard"           "$BIN/mico_dashboard.sh"

echo "========================================"
echo "TOTAL PASS: $PASS"
echo "TOTAL FAIL: $FAIL"
echo "TOTAL WARN: $WARN"
STATUS="READY"
[ $FAIL -gt 0 ] && STATUS="NOT READY"
echo "STATUS: $STATUS"
echo "Exit Code: $([ $FAIL -gt 0 ] && echo 1 || echo 0)"
echo "========================================"
notify "MICO Audit: PASS=$PASS FAIL=$FAIL WARN=$WARN STATUS=$STATUS"
exit $FAIL
