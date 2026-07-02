#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/audit_dewan_$(date +%Y%m%d_%H%M).log"
PASS=0; FAIL=0
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "╔══════════════════════════════════════════════════╗"
stamp "║   AUDIT DEWAN AGEN — PROTOKOL 10-5-3-1         ║"
stamp "║   Mencari celah & kemampuan pengambilan keputusan║"
stamp "╚══════════════════════════════════════════════════╝"

# ============================================================
# 10 CEKPOIN UTAMA
# ============================================================
stamp ""
stamp "===== 10 CEKPOIN UTAMA ====="

check() { eval "$2" 2>/dev/null && { stamp "✅ $1"; ((PASS++)); } || { stamp "❌ $1"; ((FAIL++)); }; }

check "LLM MICO (otak lokal)" "pgrep llama-server > /dev/null"
check "Node Bridge (jembatan)" "pgrep -f pocketpal_node.js > /dev/null"
check "Infinix (node kedua)" "ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1"
check "Ngrok (akses luar)" "curl -s --max-time 3 http://127.0.0.1:4040/api/tunnels | grep -q public_url"
check "SSOT (sumber kebenaran)" "[ -f ~/JDEQ/SSOT/MICO-EQ-001-FINAL.md ]"
check "Digital DNA (identitas)" "[ -f ~/JDEQ/CONSTITUTION/digital_dna.json ]"
check "Audit Trail (jejak)" "[ -f ~/JDEQ/logs/audit_trail.log ]"
check "Auto-Heal (pemulihan)" "crontab -l 2>/dev/null | grep -q auto_heal"
check "Event Bus (komunikasi)" "[ -f ~/JDEQ/CORTEX/event_bus.py ]"
check "Capability Graph (eksekusi)" "[ -f ~/JDEQ/CORTEX/capability_graph.py ]"

# ============================================================
# 5 ANALISIS MENDALAM — CELAH PER AGEN
# ============================================================
stamp ""
stamp "===== 5 ANALISIS MENDALAM — CELAH PER AGEN ====="

stamp ""
stamp "1. CHAT GPT — Arsitektur & Governance"
GPT_OK=1
[ -f ~/JDEQ/SSOT/SSOT.md ] || { stamp "  ❌ Celah: SSOT.md tidak ditemukan"; GPT_OK=0; }
[ -f ~/JDEQ/CONSTITUTION/digital_dna.json ] || { stamp "  ❌ Celah: Digital DNA tidak ditemukan"; GPT_OK=0; }
[ -f ~/JDEQ/GOVERNANCE/input_validator.json ] || { stamp "  ⚠️ Celah minor: Guard Rail belum lengkap"; }
[ $GPT_OK -eq 1 ] && stamp "  ✅ CHATGPT: Arsitektur fondasi LENGKAP"

stamp ""
stamp "2. CLAUDE — Auditor & Runtime Node"
CLAUDE_OK=1
python3 -c "import json; from pathlib import Path; print(json.loads(Path('~/JDEQ/CONSTITUTION/digital_dna.json').expanduser().read_text()).get('identity_hash',''))" 2>/dev/null | grep -q . || { stamp "  ❌ Celah: Digital DNA tidak terbaca"; CLAUDE_OK=0; }
[ -f ~/JDEQ/DAL/predictive_planner.py ] || { stamp "  ⚠️ Celah minor: Predictive Planner tidak aktif"; }
[ -f ~/JDEQ/DAL/meta_cognitive.py ] || { stamp "  ⚠️ Celah minor: Meta Cognitive tidak aktif"; }
[ $CLAUDE_OK -eq 1 ] && stamp "  ✅ CLAUDE: Fondasi node RUNTIME LENGKAP"

stamp ""
stamp "3. JARVIS / GEMINI — NLP & Voice Processing"
JARVIS_OK=1
command -v termux-tts-speak > /dev/null 2>&1 || { stamp "  ❌ Celah: TTS tidak tersedia"; JARVIS_OK=0; }
command -v termux-speech-to-text > /dev/null 2>&1 || { stamp "  ⚠️ Celah: STT terpasang, belum diuji penuh"; }
[ -f ~/JDEQ/CORTEX/intent_graph.py ] || { stamp "  ❌ Celah: Intent Graph TIDAK DITEMUKAN"; JARVIS_OK=0; }
[ $JARVIS_OK -eq 1 ] && stamp "  ✅ JARVIS/GEMINI: NLP & Intent SIAP"

stamp ""
stamp "4. PERPLEXITY — Validasi & Terobosan"
PERPLEXITY_OK=1
[ -f ~/JDEQ/GOVERNANCE/prompts/anti_hallucination_core.md ] || { stamp "  ❌ Celah: Anti-halusinasi prompt tidak ditemukan"; PERPLEXITY_OK=0; }
[ -f ~/JDEQ/GOVERNANCE/learned_rules.json ] || { stamp "  ⚠️ Celah: Learning rules belum terisi"; }
[ -f ~/JDEQ/GOVERNANCE/detect_bot.py ] || { stamp "  ⚠️ Celah: Bot detection belum aktif"; }
[ $PERPLEXITY_OK -eq 1 ] && stamp "  ✅ PERPLEXITY: Validasi terpasang, perlu pengayaan data"

stamp ""
stamp "5. CO PILOT (MICROSOFT + GITHUB) — Prosedural & Modifikasi"
COPILOT_OK=1
[ -f ~/JDEQ/bin/sensor_all.sh ] || { stamp "  ❌ Celah: Sensor bridge TIDAK DITEMUKAN"; COPILOT_OK=0; }
[ -f ~/JDEQ/bridge/macro_listener.sh ] || { stamp "  ❌ Celah: MacroDroid bridge TIDAK DITEMUKAN"; COPILOT_OK=0; }
[ -f ~/JDEQ/bridge/pocketpal_node.js ] || { stamp "  ⚠️ Celah: Node.js bridge tidak ditemukan"; }
[ $COPILOT_OK -eq 1 ] && stamp "  ✅ CO PILOT: Prosedural bridge SIAP"

stamp ""
stamp "6. EMERGENT — Automatisasi"
EMERGENT_OK=1
crontab -l 2>/dev/null | grep -q "auto_heal" || { stamp "  ❌ Celah: Auto-heal tidak terjadwal"; EMERGENT_OK=0; }
crontab -l 2>/dev/null | grep -q "sync_to_infinix" || { stamp "  ❌ Celah: Sync Infinix tidak terjadwal"; EMERGENT_OK=0; }
[ -f ~/JDEQ/bin/watchdog_infinix.sh ] || { stamp "  ⚠️ Celah: Watchdog Infinix tidak ditemukan"; }
[ $EMERGENT_OK -eq 1 ] && stamp "  ✅ EMERGENT: Automatisasi TERJADWAL"

# ============================================================
# 3 KEPUTUSAN
# ============================================================
stamp ""
stamp "===== 3 KEPUTUSAN ====="

TOTAL=$((PASS + FAIL))
SCORE=$((PASS * 100 / TOTAL))

stamp "1. Status Sistem: $PASS/$TOTAL komponen utama HIJAU ($SCORE%)"
stamp "2. Celah Paling Kritis:"
[ $COPILOT_OK -eq 0 ] && stamp "   🚨 CO PILOT — Sensor bridge & MacroDroid TIDAK LENGKAP"
[ $JARVIS_OK -eq 0 ] && stamp "   🚨 JARVIS/GEMINI — Intent Graph TIDAK DITEMUKAN"
stamp "3. Prioritas Perbaikan:"
stamp "   1. Intent Graph (JARVIS/GEMINI)"
stamp "   2. Sensor Bridge + MacroDroid (CO PILOT)"
stamp "   3. Anti-Halusinasi & Learning Rules (PERPLEXITY)"

# ============================================================
# 1 KESIMPULAN
# ============================================================
stamp ""
stamp "===== 1 KESIMPULAN ====="
stamp "Skor Audit: $SCORE%"
stamp "Fase: Brain Stem → Cortex (80% selesai)"
stamp "Celah terbesar: Intent Graph (NLP) & Sensor Bridge (Otomasi)"
stamp "Target: Lengkapi 2 komponen ini untuk mencapai 95%"

# ============================================================
# 5 PERTANYAAN MANDIRI
# ============================================================
stamp ""
stamp "===== 5 PERTANYAAN MANDIRI ====="
stamp "1. Apakah MICO bisa memahami suara? $( [ -f ~/JDEQ/CORTEX/intent_graph.py ] && echo '✅' || echo '❌ — PRIORITAS UTAMA')"
stamp "2. Apakah MICO bisa menjalankan aksi fisik? $( [ -f ~/JDEQ/bridge/macro_listener.sh ] && echo '✅' || echo '❌ — PRIORITAS UTAMA')"
stamp "3. Apakah MICO bisa pulih sendiri? $( crontab -l 2>/dev/null | grep -q auto_heal && echo '✅' || echo '❌')"
stamp "4. Apakah SSOT utuh? $( [ -f ~/JDEQ/SSOT/MICO-EQ-001-FINAL.md ] && echo '✅' || echo '❌')"
stamp "5. Apakah Infinix siap 24/7? $( ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1 && echo '✅' || echo '❌')"

stamp ""
stamp "============================================"
stamp "  Audit selesai. Log: $LOG"
stamp "============================================"
