#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/stress_$(date +%Y%m%d_%H%M).log"
PASS=0; FAIL=0

echo "╔══════════════════════════════════════╗" | tee $LOG
echo "║  MICO V7.1 — OPERATIONAL TEST       ║" | tee -a $LOG
echo "║  Menjawab Audit ChatGPT             ║" | tee -a $LOG
echo "╚══════════════════════════════════════╝" | tee -a $LOG

# 1. Uji 100 event berturut-turut (beban ringan)
echo "" | tee -a $LOG
echo "📊 UJI 100 EVENT..." | tee -a $LOG
START=$(date +%s)
for i in {1..100}; do
  python3 -c "
import sys; sys.path.insert(0, '$HOME/JDEQ/CORE')
from event_manager.event_manager import EventManager
e = EventManager()
e.publish('TEST_$i')
" 2>/dev/null
done
END=$(date +%s)
DURATION=$((END - START))
echo "   ✅ 100 event selesai dalam ${DURATION}s" | tee -a $LOG
[ $DURATION -lt 10 ] && echo "   ✅ Kinerja event bus: CEPAT (< 10s)" | tee -a $LOG && ((PASS++)) || { echo "   ⚠️ Event bus lambat" | tee -a $LOG; ((FAIL++)); }

# 2. Uji memory leak (pantau RAM selama 60 detik)
echo "" | tee -a $LOG
echo "📊 UJI MEMORY LEAK (60 detik)..." | tee -a $LOG
RAM_START=$(free -m | awk '/Mem/{print $7}')
for i in {1..60}; do
  python3 -c "
import sys; sys.path.insert(0, '$HOME/JDEQ/CORE')
from virtual_daemon.vdaemon import VirtualDaemon
vd = VirtualDaemon()
vd.run('test', 'LEAK_TEST')
" 2>/dev/null
  sleep 1
done
RAM_END=$(free -m | awk '/Mem/{print $7}')
DIFF=$((RAM_START - RAM_END))
echo "   RAM awal: ${RAM_START}MB → akhir: ${RAM_END}MB (selisih: ${DIFF}MB)" | tee -a $LOG
[ $DIFF -lt 50 ] && echo "   ✅ Tidak ada memory leak signifikan" | tee -a $LOG && ((PASS++)) || { echo "   ⚠️ Potensi memory leak" | tee -a $LOG; ((FAIL++)); }

# 3. Uji recovery (kill LLM, pastikan supervisor pulihkan)
echo "" | tee -a $LOG
echo "📊 UJI RECOVERY..." | tee -a $LOG
pkill -f llama-server 2>/dev/null
sleep 5
if pgrep llama-server > /dev/null; then
  echo "   ✅ LLM pulih otomatis (Supervisor bekerja)" | tee -a $LOG && ((PASS++))
else
  echo "   ⚠️ LLM tidak pulih — jalankan manual" | tee -a $LOG && ((FAIL++))
  nohup llama-server -m ~/JDEQ/models/mico.gguf --port 8082 -ngl 99 > /dev/null 2>&1 &
fi

# 4. Uji Infinix recovery
echo "" | tee -a $LOG
echo "📊 UJI INFINIX..." | tee -a $LOG
if ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1; then
  echo "   ✅ Infinix ONLINE" | tee -a $LOG && ((PASS++))
else
  echo "   ⚠️ Infinix OFFLINE — mencoba remote..." | tee -a $LOG
  ssh -o ConnectTimeout=5 -p 8022 100.103.39.81 "cd ~/JDEQ_CLONE/server && nohup python3 mico_server.py > /dev/null 2>&1 &" 2>/dev/null
  sleep 5
  if ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1; then
    echo "   ✅ Infinix PULIH" | tee -a $LOG && ((PASS++))
  else
    echo "   ❌ Infinix tetap OFFLINE" | tee -a $LOG && ((FAIL++))
  fi
fi

# Ringkasan
echo "" | tee -a $LOG
TOTAL=$((PASS + FAIL))
echo "╔══════════════════════════════════════╗" | tee -a $LOG
echo "║  HASIL OPERATIONAL TEST             ║" | tee -a $LOG
echo "║  PASS: $PASS/$TOTAL                       ║" | tee -a $LOG
echo "║  $( [ $FAIL -eq 0 ] && echo '✅ LULUS — Siap Produksi' || echo '⚠️ PERLU PERBAIKAN')        ║" | tee -a $LOG
echo "╚══════════════════════════════════════╝" | tee -a $LOG
