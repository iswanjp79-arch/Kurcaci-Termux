#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/check_modules.log"
echo "=== PEMERIKSAAN MODUL MICO ===" | tee $LOG
echo "" | tee -a $LOG

echo "🏗️  FONDASI (Brain Stem):" | tee -a $LOG
for mod in "decision_kernel" "node000_homeostasis" "audit_engine" "learning_engine" "orchestrator"; do
  if find ~/JDEQ -name "${mod}.py" 2>/dev/null | grep -q .; then
    echo "✅ $mod" | tee -a $LOG
  else
    echo "❌ $mod TIDAK DITEMUKAN" | tee -a $LOG
  fi
done

echo "" | tee -a $LOG
echo "🧠 CORTEX (Otak):" | tee -a $LOG
for mod in "event_bus" "context_builder" "intent_graph" "capability_graph"; do
  if find ~/JDEQ -name "${mod}.py" 2>/dev/null | grep -q .; then
    echo "✅ $mod" | tee -a $LOG
  else
    echo "❌ $mod TIDAK DITEMUKAN" | tee -a $LOG
  fi
done

echo "" | tee -a $LOG
echo "=== STATUS PROSES ===" | tee -a $LOG
pgrep -f "llama-server" > /dev/null && echo "✅ LLM AKTIF" | tee -a $LOG || echo "❌ LLM MATI" | tee -a $LOG
pgrep -f "node000_homeostasis" > /dev/null && echo "✅ Homeostasis berjalan" | tee -a $LOG || echo "❌ Homeostasis mati" | tee -a $LOG

echo "✅ Pemeriksaan selesai" | tee -a $LOG
