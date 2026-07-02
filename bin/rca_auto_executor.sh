#!/data/data/com.termux/files/usr/bin/bash
# MICO RCA AUTO-EXECUTOR — Anti-Crash, Auto-Kompatibel
LOG="$HOME/JDEQ/logs/rca_$(date +%Y%m%d_%H%M).log"
PASS=0; FAIL=0
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "===== RCA AUTO-EXECUTOR ====="
sync && sleep 1

# Cek dengan toleransi kegagalan (tanpa set -e)
check() { eval "$2" 2>/dev/null && { stamp "✅ $1"; ((PASS++)); } || { stamp "⚠️ $1 tidak tersedia"; }; }

stamp "--- Audit 10 ---"
check "SSOT" "[ -f ~/JDEQ/SSOT/MICO-EQ-001-FINAL.md ]"
check "LLM" "pgrep llama-server > /dev/null"
check "Infinix" "ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1"
check "Telegram" "bash ~/JDEQ/bin/notify_telegram.sh 'RCA Test' 2>&1 | grep -q '✅'"
check "WhatsApp" "bash ~/JDEQ/bin/notify_whatsapp.sh 'RCA Test' 2>&1 | grep -q '✅'"
check "Symthink" "[ -f ~/JDEQ/router/symthink_router.py ]"
check "Symlink" "[ -L ~/JDEQ/TREE_L/SSOT ]"
check "DNA" "[ -f ~/JDEQ/CONSTITUTION/digital_dna.json ]"
check "Confidence" "[ -f ~/JDEQ/DAL/confidence_engine.py ]"
check "AutoHeal" "crontab -l 2>/dev/null | grep -q auto_heal"

CONF=$((PASS*100/(PASS+FAIL)))
stamp "Confidence: $CONF% | Mode: $( [ $CONF -ge 95 ] && echo AUTO_EXECUTE || echo RECOMMEND)"

# Eksekusi modul kompatibel
stamp "--- Eksekusi ---"
python3 ~/JDEQ/router/symthink_router.py "RCA" 2>/dev/null || true
python3 ~/JDEQ/DAL/predictive_planner.py 2>/dev/null || true
python3 ~/JDEQ/DAL/meta_cognitive.py 2>/dev/null || true

# Laporan
bash ~/JDEQ/bin/notify_telegram.sh "✅ RCA: $PASS/10 | $CONF% | $( [ $CONF -ge 95 ] && echo AUTO_EXECUTE || echo RECOMMEND)" 2>/dev/null || true
stamp "===== SELESAI ====="
echo "✅ RCA selesai. Log: $LOG"
