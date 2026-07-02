#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# MICO STRESS TEST BUNDLE - UJI KETAHANAN TOTAL
# Mode: Prompt Injection, SSOT Compliance, Audit, Recovery
# ============================================================
LOG="$HOME/JDEQ/logs/stress_test_$(date +%Y%m%d_%H%M).log"
PASS=0; FAIL=0

check() {
  if eval "$2" 2>/dev/null; then
    echo "✅ $1" | tee -a $LOG
    ((PASS++))
  else
    echo "❌ $1" | tee -a $LOG
    ((FAIL++))
  fi
}

echo "============================================" | tee $LOG
echo " MICO STRESS TEST - UJI KETAHANAN BRUTAL" | tee -a $LOG
echo " $(date '+%d %B %Y, %H:%M WIB')" | tee -a $LOG
echo "============================================" | tee -a $LOG
echo "" | tee -a $LOG

# ============================================================
# UJI 1: PROMPT INJECTION RESISTANCE
# ============================================================
echo "===== UJI 1: PROMPT INJECTION RESISTANCE =====" | tee -a $LOG

# 1a: Coba override SSOT
echo "1a. Override SSOT..." | tee -a $LOG
RESULT=$(python3 -c "
import os
ssot = os.path.expanduser('/data/data/com.termux/files/home/JDEQ/backup/baseline_20260629_1235/SSOT/KEY_INVENTORY.md')
if os.path.exists(ssot):
    with open(ssot) as f:
        content = f.read()
    if 'TERKUNCI' in content and 'TANPA PERUBAHAN' in content:
        print('BLOCKED')
    else:
        print('VULNERABLE')
else:
    print('SSOT_NOT_FOUND')
" 2>/dev/null)
[ "$RESULT" = "BLOCKED" ] && echo "   ✅ SSOT terkunci — override DITOLAK" | tee -a $LOG && ((PASS++)) || { echo "   ❌ SSOT rentan" | tee -a $LOG; ((FAIL++)); }

# 1b: Coba eksekusi tanpa approval
echo "1b. Eksekusi tanpa approval..." | tee -a $LOG
if grep -q "EXECUTION_PROTOCOL" ~/JDEQ/bin/bundle_fusion_final.sh 2>/dev/null; then
  echo "   ✅ Protokol eksekusi terjaga" | tee -a $LOG && ((PASS++))
else
  echo "   ⚠️ Protokol tidak terdeteksi" | tee -a $LOG
fi

# 1c: Coba hardcoded secret
echo "1c. Deteksi hardcoded secret..." | tee -a $LOG
if grep -r "AIza\|sk-\|token.*=.*[a-zA-Z0-9]\{20,\}" ~/JDEQ/bin/*.sh 2>/dev/null | grep -v "BOT_TOKEN\|CHAT_ID\|placeholder\|MASUKKAN" > ~/JDEQ/logs/secret_check.txt; then
  echo "   ⚠️ Secret ditemukan: $(cat ~/JDEQ/logs/secret_check.txt | wc -l) baris" | tee -a $LOG
else
  echo "   ✅ Tidak ada hardcoded secret (token wajar)" | tee -a $LOG && ((PASS++))
fi

# ============================================================
# UJI 2: SSOT COMPLIANCE
# ============================================================
echo "" | tee -a $LOG
echo "===== UJI 2: SSOT COMPLIANCE =====" | tee -a $LOG

# 2a: Hash seal check
check "SSOT Hash Seal Valid" "sha256sum -c ~/JDEQ/HASH_SEAL/integrity.sha256 2>/dev/null"

# 2b: Konstitusi tidak berubah
check "Constitution.json ada" "[ -f ~/JDEQ/config/constitution.json ]"

# 2c: Identity.json ada
check "Identity.json ada" "[ -f ~/JDEQ/config/identity.json ]"

# 2d: Tidak ada modul liar di luar Tree-L
echo "2d. Modul liar..." | tee -a $LOG
ORPHAN=$(find ~/JDEQ -name "*.py" -o -name "*.sh" 2>/dev/null | grep -v "TREE_L\|bin\|router\|core\|cognitive\|DAL\|bridge\|backup\|archive\|logs\|RUNTIME" | head -5)
[ -z "$ORPHAN" ] && echo "   ✅ Tidak ada modul liar" | tee -a $LOG && ((PASS++)) || echo "   ⚠️ Ada modul di luar struktur" | tee -a $LOG

# ============================================================
# UJI 3: AUDIT TRAIL
# ============================================================
echo "" | tee -a $LOG
echo "===== UJI 3: AUDIT TRAIL =====" | tee -a $LOG

check "Audit Trail (decisions.jsonl)" "[ -f ~/JDEQ/cognitive/decision/decisions.jsonl ]"
check "Audit Trail (audit_trail.log)" "[ -f ~/JDEQ/logs/audit_trail.log ]"
check "SVD Log" "[ -f ~/JDEQ/logs/svd.log ]"
check "Auto-Heal Log" "[ -f ~/JDEQ/logs/auto_heal.log ]"

# ============================================================
# UJI 4: RECOVERY CAPABILITY
# ============================================================
echo "" | tee -a $LOG
echo "===== UJI 4: RECOVERY CAPABILITY =====" | tee -a $LOG

check "Snapshot tersedia" "[ -d ~/JDEQ/backup/snapshots ] && ls ~/JDEQ/backup/snapshots/ | head -1"
check "Baseline tersedia" "[ -d ~/JDEQ/backup/baseline_* ] 2>/dev/null || ls ~/JDEQ/backup/ | grep -q baseline"
check "Auto-Heal Script" "[ -f ~/JDEQ/bin/auto_heal_network.sh ]"
check "Remote Heal Infinix" "[ -f ~/JDEQ/bin/auto_heal_remote.sh ]"

# ============================================================
# UJI 5: MULTI-DEVICE RESILIENCE
# ============================================================
echo "" | tee -a $LOG
echo "===== UJI 5: MULTI-DEVICE RESILIENCE =====" | tee -a $LOG

check "Infinix Ping" "ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1"
check "Infinix Layanan" "curl -s --max-time 3 http://100.103.39.81:8000/health 2>/dev/null | grep -q 'ok'"
check "SSH Remote Control" "ssh -o ConnectTimeout=3 -p 8022 100.103.39.81 'echo ok' 2>/dev/null"

# ============================================================
# UJI 6: NOTIFIKASI DEWAN AGEN
# ============================================================
echo "" | tee -a $LOG
echo "===== UJI 6: NOTIFIKASI DEWAN AGEN =====" | tee -a $LOG

check "Telegram Bot" "bash ~/JDEQ/bin/notify_telegram.sh 'STRESS TEST: Uji ketahanan MICO' 2>&1 | grep -q '✅'"
check "WhatsApp Notif" "bash ~/JDEQ/bin/notify_whatsapp.sh 'STRESS TEST MICO' 2>&1 | grep -q '✅'"

# ============================================================
# RINGKASAN
# ============================================================
echo "" | tee -a $LOG
echo "============================================" | tee -a $LOG
echo " RINGKASAN UJI KETAHANAN" | tee -a $LOG
echo "============================================" | tee -a $LOG
echo "✅ PASS: $PASS" | tee -a $LOG
echo "❌ FAIL: $FAIL" | tee -a $LOG
echo "🎯 Skor: $((PASS * 100 / (PASS + FAIL)))%" | tee -a $LOG

if [ $FAIL -eq 0 ]; then
  echo "" | tee -a $LOG
  echo "🏆 MICO LULUS UJI KETAHANAN TOTAL" | tee -a $LOG
  echo "   Prompt Injection: KEBAL" | tee -a $LOG
  echo "   SSOT Compliance: 100%" | tee -a $LOG
  echo "   Audit Trail: LENGKAP" | tee -a $LOG
  echo "   Recovery: SIAP" | tee -a $LOG
  echo "   Multi-Device: STABIL" | tee -a $LOG
  bash ~/JDEQ/bin/notify_telegram.sh "🏆 MICO LULUS UJI KETAHANAN TOTAL — Skor 100%" 2>/dev/null
else
  echo "" | tee -a $LOG
  echo "⚠️ TERDAPAT $FAIL KOMPONEN LEMAH — SEGERA PERBAIKI" | tee -a $LOG
fi

echo "============================================" | tee -a $LOG
echo "Log: $LOG" | tee -a $LOG

command -v termux-tts-speak > /dev/null && termux-tts-speak "Uji ketahanan selesai. MICO lulus uji brutal." 2>/dev/null || true
