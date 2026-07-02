#!/bin/bash
JDEQ="/data/data/com.termux/files/home/JDEQ"

route_command() {
    case $1 in
        rab|RAB|anggaran)
            python3 "$JDEQ/PROJECT_CONTROL/rab_engine.py"
            ;;
        cpm|CPM|jadwal)
            python3 "$JDEQ/PROJECT_CONTROL/orchestrator.py"
            ;;
        evm|EVM|performa)
            python3 "$JDEQ/PROJECT_CONTROL/evm_engine.py"
            ;;
        dashboard|status)
            python3 "$JDEQ/CORE_ORCHESTRATION/mico_dashboard.py"
            ;;
        reason|analisa)
            python3 -c "
import sys; sys.path.insert(0, '$JDEQ/CORE_REASONING')
from engineering_rule_engine import engineering_reasoning
hasil = engineering_reasoning('$2')
print('[MICO] Analisa:', hasil.get('analysis', {}).get('classification', '?'))
print('[MICO] Keputusan:', hasil.get('decision', '?'))
"
            ;;
        audit|log)
            tail -10 "$JDEQ/CORE_MEMORY/logs/audit.log"
            ;;
        secure|keamanan)
            python3 "$JDEQ/CORE_SECURITY/security_hardening.py"
            python3 "$JDEQ/CORE_SECURITY/recovery_manager.py"
            ;;
        recover|pulih)
            python3 "$JDEQ/CORE_SECURITY/recovery_manager.py"
            ;;
        *)
            echo "[MICO] Perintah ora dikenal. Coba: rab, cpm, evm, dashboard, reason [teks], audit, secure, recover"
            ;;
    esac
}

if [ $# -eq 0 ]; then
    while true; do
        echo -n "MICO > "
        read -a args
        [ "${args[0]}" = "exit" ] && break
        route_command "${args[0]}" "${args[*]:1}"
    done
else
    route_command "$1" "${*:2}"
fi
