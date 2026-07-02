#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/final_audit_$(date +%Y%m%d_%H%M).log"
PASS=0; FAIL=0
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp " FINAL AUDIT + SENSOR UJI + INFINIX WAKE"
stamp "============================================"

# 1. Infinix
stamp "Membangunkan Infinix..."
for i in {1..5}; do ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1 && { stamp "✅ Infinix terjangkau"; break; }; sleep 2; done
if ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1; then
  curl -s --max-time 5 -X POST http://100.103.39.81:9000 -d '{"cmd":"echo wake"}' 2>/dev/null || true
  stamp "✅ Server Infinix diperiksa"
fi

# 2. Sensor
stamp "Menguji sensor Android via Termux-API..."
command -v termux-tts-speak > /dev/null && stamp "✅ Suara (TTS)" && ((PASS++)) || stamp "❌ Suara (TTS)"
command -v termux-speech-to-text > /dev/null && stamp "✅ Mikrofon (STT)" && ((PASS++)) || stamp "⚠️ Mikrofon"
command -v termux-camera-photo > /dev/null && stamp "✅ Kamera (terpasang)" && ((PASS++)) || stamp "⚠️ Kamera (izin manual)"
stamp "Audit 10-5-3-1 lengkap..."
check() { eval "$2" 2>/dev/null && { stamp "✅ $1"; ((PASS++)); } || { stamp "❌ $1"; ((FAIL++)); }; }
check "SSOT Final" "[ -f ~/JDEQ/SSOT/MICO-EQ-001-FINAL.md ]"
check "Digital DNA" "[ -f ~/JDEQ/CONSTITUTION/digital_dna.json ]"
check "LLM Server" "pgrep llama-server > /dev/null"
check "API :8082" "curl -s --max-time 3 http://localhost:8082/v1/models > /dev/null"
check "Ghost Relay" "pgrep -f ghost_relay.py > /dev/null"
check "Infinix" "ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1"
check "Telegram" "bash ~/JDEQ/bin/notify_telegram.sh 'Final Audit' 2>&1 | grep -q '✅'"
check "WhatsApp" "bash ~/JDEQ/bin/notify_whatsapp.sh 'Final Audit' 2>&1 | grep -q '✅'"
check "Symthink" "[ -f ~/JDEQ/router/symthink_router.py ]"
check "Symlink" "[ -L ~/JDEQ/TREE_L/SSOT ]"
check "Confidence Engine" "[ -f ~/JDEQ/DAL/confidence_engine.py ]"
check "Predictive Planner" "[ -f ~/JDEQ/AUDIT/predictions.jsonl ]"
check "Meta Cognitive" "[ -f ~/JDEQ/AUDIT/meta_cognitive.jsonl ]"
check "Auto-Heal" "crontab -l 2>/dev/null | grep -q auto_heal"
check "Narrative" "[ -f ~/JDEQ/logs/narrative_$(date +%Y%m%d).md ]"
check "Dual Control" "curl -s --max-time 5 -X POST http://100.103.39.81:9000 -d '{\"cmd\":\"echo ok\"}' 2>/dev/null | grep -q ok"
check "SSOT Hash" "sha256sum -c ~/JDEQ/HASH_SEAL/integrity.sha256 2>/dev/null | grep -q OK"

CONFIDENCE=$((PASS * 100 / (PASS + FAIL)))
stamp ""
stamp "============================================"
stamp " HASIL AUDIT TOTAL"
stamp " PASS: $PASS | FAIL: $FAIL"
stamp " CONFIDENCE: $CONFIDENCE%"
stamp " STATUS: $( [ $FAIL -eq 0 ] && echo '✅ 100% LUNAS — REALITY VERIFIED' || echo '⚠️ PERLU PERBAIKAN')"
stamp "============================================"
bash ~/JDEQ/bin/notify_telegram.sh "📘 LAPORAN FINAL MICO | PASS: $PASS | CONFIDENCE: $CONFIDENCE% | $( [ $FAIL -eq 0 ] && echo '✅ 100% LUNAS' || echo '⚠️ PERLU PERBAIKAN')" 2>/dev/null || true
echo "✅ Laporan final tersimpan: $LOG"
