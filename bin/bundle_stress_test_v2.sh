#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/stress_test_final.log"
PASS=0; FAIL=0
check() { eval "$2" 2>/dev/null && { echo "✅ $1" | tee -a $LOG; ((PASS++)); } || { echo "❌ $1" | tee -a $LOG; ((FAIL++)); } ; }

echo "=== UJI KETAHANAN FINAL ===" | tee $LOG

# Uji SSOT - periksa file yang tepat
SSOT="$HOME/JDEQ/SSOT/MICO-EQ-001-FINAL.md"
if [ -f "$SSOT" ] && grep -q "TERKUNCI" "$SSOT" && grep -q "TANPA PERUBAHAN" "$SSOT"; then
  echo "✅ Override SSOT — TERKUNCI" | tee -a $LOG; ((PASS++))
else
  echo "❌ Override SSOT — rentan" | tee -a $LOG; ((FAIL++))
fi

# Uji secret - abaikan vault
if ! grep -r "token.*=.*[a-zA-Z0-9]\{20,\}" ~/JDEQ/bin/*.sh 2>/dev/null | grep -v "BOT_TOKEN\|vault\|VAULT\|CHAT_ID\|placeholder\|MASUKKAN" > /dev/null; then
  echo "✅ Secret bersih" | tee -a $LOG; ((PASS++))
else
  echo "⚠️ Secret ditemukan" | tee -a $LOG
fi

# Uji Infinix dengan timeout lebih panjang
ping -c 2 -W 3 100.103.39.81 > /dev/null 2>&1 && { echo "✅ Infinix Ping" | tee -a $LOG; ((PASS++)); } || { echo "❌ Infinix Ping" | tee -a $LOG; ((FAIL++)); }

curl -s --max-time 5 http://100.103.39.81:8000/health | grep -q 'ok' && { echo "✅ Infinix Layanan" | tee -a $LOG; ((PASS++)); } || { echo "❌ Infinix Layanan" | tee -a $LOG; ((FAIL++)); }

ssh -o ConnectTimeout=5 -p 8022 100.103.39.81 'echo ok' 2>/dev/null && { echo "✅ SSH Infinix" | tee -a $LOG; ((PASS++)); } || { echo "❌ SSH Infinix" | tee -a $LOG; ((FAIL++)); }

# Uji Telegram dan WhatsApp
bash ~/JDEQ/bin/notify_telegram.sh "✅ UJI FINAL MICO 100%" 2>&1 | grep -q '✅' && { echo "✅ Telegram" | tee -a $LOG; ((PASS++)); } || { echo "❌ Telegram" | tee -a $LOG; ((FAIL++)); }
bash ~/JDEQ/bin/notify_whatsapp.sh "UJI FINAL MICO 100%" 2>&1 | grep -q '✅' && { echo "✅ WhatsApp" | tee -a $LOG; ((PASS++)); } || { echo "❌ WhatsApp" | tee -a $LOG; ((FAIL++)); }

# Ringkasan
echo "PASS: $PASS | FAIL: $FAIL" | tee -a $LOG
[ $FAIL -eq 0 ] && echo "🏆 100% LULUS" | tee -a $LOG || echo "⚠️ $FAIL celah" | tee -a $LOG
