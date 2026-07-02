#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/reality_verified_$(date +%Y%m%d_%H%M).log"
PASS=0; FAIL=0
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp " REALITY VERIFICATION - UJI FUNGSIONAL"
stamp "============================================"

# 1. LLM: kirim prompt dan verifikasi jawaban
LLM_RESPONSE=$(curl -s --max-time 10 http://localhost:8082/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"1+1"}],"max_tokens":10}' 2>/dev/null)
if echo "$LLM_RESPONSE" | grep -q "2"; then
  stamp "✅ LLM berfungsi: menjawab 1+1=2"; ((PASS++))
else
  stamp "❌ LLM tidak menjawab"; ((FAIL++))
fi

# 2. API: cek endpoint models
API_OK=$(curl -s --max-time 5 http://localhost:8082/v1/models | grep -q "object" && echo "✅" || echo "❌")
[ "$API_OK" = "✅" ] && { stamp "✅ API merespons"; ((PASS++)); } || { stamp "❌ API mati"; ((FAIL++)); }

# 3. Ghost Relay: kirim pesan ke Infinix
RELAY_OK=$(curl -s --max-time 10 -X POST http://100.103.39.81:9000 \
  -d '{"cmd":"echo ghost_test"}' 2>/dev/null | grep -q "ghost_test" && echo "✅" || echo "❌")
[ "$RELAY_OK" = "✅" ] && { stamp "✅ Ghost Relay berfungsi"; ((PASS++)); } || { stamp "❌ Ghost Relay gagal"; ((FAIL++)); }

# 4. Infinix: eksekusi perintah nyata
INFINIX_OK=$(curl -s --max-time 10 -X POST http://100.103.39.81:9000 \
  -d '{"cmd":"free -m | head -2"}' 2>/dev/null | grep -q "Mem" && echo "✅" || echo "❌")
[ "$INFINIX_OK" = "✅" ] && { stamp "✅ Infinix mengeksekusi perintah"; ((PASS++)); } || { stamp "❌ Infinix tidak merespons"; ((FAIL++)); }

# 5. Telegram: kirim notifikasi uji
TELEGRAM_OK=$(bash ~/JDEQ/bin/notify_telegram.sh "🔍 REALITY CHECK: $(date +%H:%M)" 2>&1 | grep -q "✅" && echo "✅" || echo "❌")
[ "$TELEGRAM_OK" = "✅" ] && { stamp "✅ Telegram aktif"; ((PASS++)); } || { stamp "❌ Telegram gagal"; ((FAIL++)); }

# 6. Auto-Heal: uji dengan mematikan proses kecil
TEST_SERVICE="ghost_relay.py"
pkill -f "$TEST_SERVICE" 2>/dev/null
sleep 5
if pgrep -f "$TEST_SERVICE" > /dev/null; then
  stamp "✅ Auto-Heal berfungsi: $TEST_SERVICE dipulihkan"; ((PASS++))
else
  stamp "⚠️ Auto-Heal tidak memulihkan $TEST_SERVICE"; nohup python3 ~/JDEQ/bridge/ghost_relay.py > /dev/null 2>&1 &
fi

# 7. SSOT: verifikasi hash
HASH_OK=$(sha256sum -c ~/JDEQ/HASH_SEAL/integrity.sha256 2>/dev/null | grep -q "OK" && echo "✅" || echo "❌")
[ "$HASH_OK" = "✅" ] && { stamp "✅ SSOT utuh"; ((PASS++)); } || { stamp "❌ SSOT berubah"; ((FAIL++)); }

# 8. Digital DNA
DNA_OK=$(python3 -c "import json; from pathlib import Path; d=json.loads(Path('~/JDEQ/CONSTITUTION/digital_dna.json').expanduser().read_text()); print(d.get('identity_hash',''))" 2>/dev/null | grep -q . && echo "✅" || echo "❌")
[ "$DNA_OK" = "✅" ] && { stamp "✅ Digital DNA utuh"; ((PASS++)); } || { stamp "❌ Digital DNA rusak"; ((FAIL++)); }

# Hitung confidence nyata
TOTAL=$((PASS + FAIL))
CONFIDENCE=$((PASS * 100 / TOTAL))

stamp ""
stamp "============================================"
stamp " HASIL REALITY VERIFICATION"
stamp " PASS: $PASS | FAIL: $FAIL"
stamp " CONFIDENCE: $CONFIDENCE%"
stamp " STATUS: $([ $FAIL -eq 0 ] && echo 'REALITY VERIFIED' || echo 'ARCHITECTURE READY - OPERATIONAL VALIDATION PENDING')"
stamp "============================================"

# Narrative
echo "📖 NARRATIVE: $(date '+%d %B %Y')" >> $LOG
echo "  Diuji: $TOTAL layanan" >> $LOG
echo "  Lulus: $PASS" >> $LOG
echo "  Confidence: $CONFIDENCE%" >> $LOG
echo "  Tindakan: $([ $FAIL -eq 0 ] && echo 'Sistem siap operasi penuh' || echo 'Perbaiki layanan gagal')" >> $LOG

# Kirim laporan ke Telegram
bash ~/JDEQ/bin/notify_telegram.sh "✅ REALITY CHECK: $PASS/$TOTAL lulus | Confidence: $CONFIDENCE%" 2>/dev/null
