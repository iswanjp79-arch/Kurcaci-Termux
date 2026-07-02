#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# MICO MULTI-CLOUD, NOTIFIKASI, TREE-L SYNC
# Telegram, WhatsApp, 10 Gmail, OneDrive, Infinix, Colab
# ============================================================
set -e
LOG="$HOME/JDEQ/logs/multi_cloud_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp " BUNDLE MULTI-CLOUD & NOTIFIKASI"
stamp "============================================"

# ============================================================
# 1. SETUP TREE-L VIVO (STRUKTUR FOLDER YANG DISINKRONKAN)
# ============================================================
stamp ""
stamp "===== TREE-L: STRUKTUR FOLDER SINKRONISASI ====="
mkdir -p ~/JDEQ/TREE_L/{SSOT,DAL,cognitive,config,logs,memory}

# Buat symlink untuk folder yang akan disinkronkan
ln -sf ~/JDEQ/SSOT ~/JDEQ/TREE_L/SSOT 2>/dev/null || true
ln -sf ~/JDEQ/DAL ~/JDEQ/TREE_L/DAL 2>/dev/null || true
ln -sf ~/JDEQ/cognitive ~/JDEQ/TREE_L/cognitive 2>/dev/null || true
ln -sf ~/JDEQ/config ~/JDEQ/TREE_L/config 2>/dev/null || true
ln -sf ~/JDEQ/logs ~/JDEQ/TREE_L/logs 2>/dev/null || true
ln -sf ~/JDEQ/memory ~/JDEQ/TREE_L/memory 2>/dev/null || true

stamp "✅ Tree-L Vivo terstruktur"

# ============================================================
# 2. SINKRONISASI KE 10 GMAIL + ONEDRIVE (RCLONE ROUND-ROBIN)
# ============================================================
stamp ""
stamp "===== SINKRONISASI MULTI-CLOUD ====="

cat > ~/JDEQ/bin/sync_multi_cloud.sh << 'SYNCALL'
#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/multi_cloud_sync.log"
RCLONE_CONFIG="$HOME/JDEQ/config/rclone_multi.conf"
REMITES=("gmail1" "gmail2" "gmail3" "gmail4" "gmail5" "gmail6" "gmail7" "gmail8" "gmail9" "gmail10" "onedrive")
TREE="$HOME/JDEQ/TREE_L"

for REMOTE in "${REMITES[@]}"; do
  echo "[$(date)] Sinkronisasi ke $REMOTE" >> $LOG
  rclone --config $RCLONE_CONFIG sync $TREE $REMOTE:MICO_Tree_L --progress --timeout 30s 2>&1 | tail -1 >> $LOG
  if [ $? -eq 0 ]; then
    echo "  ✅ $REMOTE sukses" >> $LOG
  else
    echo "  ⚠️ $REMOTE gagal (mungkin belum auth)" >> $LOG
  fi
done

# Sinkronisasi ke Infinix via SSH
ssh -p 8022 -o ConnectTimeout=5 100.103.39.81 "mkdir -p ~/JDEQ_CLONE/TREE_L" 2>/dev/null && \
  rsync -avz -e "ssh -p 8022" $TREE/ 100.103.39.81:~/JDEQ_CLONE/TREE_L/ 2>&1 | tail -1 >> $LOG && \
  echo "[$(date)]  ✅ Infinix sync sukses" >> $LOG || \
  echo "[$(date)]  ⚠️ Infinix sync gagal" >> $LOG

# Sinkronisasi ke Colab (jika ada endpoint)
# curl -X POST http://colab-ip:8082/sync -d @$TREE/manifest.json 2>/dev/null
echo "[$(date)] Sync selesai" >> $LOG
SYNCALL
chmod +x ~/JDEQ/bin/sync_multi_cloud.sh
stamp "✅ Skrip sync multi-cloud terpasang"

# ============================================================
# 3. NOTIFIKASI TELEGRAM & WHATSAPP
# ============================================================
stamp ""
stamp "===== NOTIFIKASI TELEGRAM & WHATSAPP ====="

# Notifikasi via Telegram Bot
cat > ~/JDEQ/bin/notify_telegram.sh << 'TELE'
#!/data/data/com.termux/files/usr/bin/bash
# Pakai: bash notify_telegram.sh "Pesan"
BOT_TOKEN="YOUR_BOT_TOKEN"  # Ganti dengan token bot Telegram
CHAT_ID="YOUR_CHAT_ID"      # Ganti dengan chat ID
MSG="$*"
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" -d "text=$MSG" > /dev/null 2>&1 && \
  echo "✅ Telegram terkirim" || echo "⚠️ Telegram gagal"
TELE
chmod +x ~/JDEQ/bin/notify_telegram.sh

# Notifikasi via WhatsApp (menggunakan Termux:API atau HTTP ke bot)
cat > ~/JDEQ/bin/notify_whatsapp.sh << 'WA'
#!/data/data/com.termux/files/usr/bin/bash
# Pakai: bash notify_whatsapp.sh "Pesan"
MSG="$*"
# Opsi 1: Via termux-share (buka aplikasi WhatsApp)
echo "$MSG" | termux-share -a send 2>/dev/null && echo "✅ WhatsApp share terbuka" || \
  echo "⚠️ WhatsApp share gagal"
# Opsi 2: Via HTTP bot (jika punya)
# curl -s -X POST "http://whatsapp-bot-api/send" -d "text=$MSG"
WA
chmod +x ~/JDEQ/bin/notify_whatsapp.sh

stamp "✅ Notifikasi Telegram & WhatsApp terpasang"

# ============================================================
# 4. LAPORAN HARIAN OTOMATIS KE DEWAN AGEN
# ============================================================
stamp ""
stamp "===== LAPORAN HARIAN OTOMATIS ====="

cat > ~/JDEQ/bin/daily_report.sh << 'REPORT'
#!/data/data/com.termux/files/usr/bin/bash
REPORT_FILE="$HOME/JDEQ/logs/daily_report_$(date +%Y%m%d).txt"

echo "========================================" > $REPORT_FILE
echo " LAPORAN HARIAN MICO-JDEQ" >> $REPORT_FILE
echo " Tanggal: $(date)" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
bash ~/JDEQ/bin/dashboard.sh >> $REPORT_FILE 2>&1
echo "" >> $REPORT_FILE
echo "📋 Keputusan hari ini:" >> $REPORT_FILE
python3 -c "
import os, json
log = os.path.expanduser('~/JDEQ/cognitive/decision/decisions.jsonl')
if os.path.exists(log):
    with open(log) as f:
        lines = f.readlines()
    for l in lines[-5:]:
        d = json.loads(l)
        print(f\"  - {d['chosen']} ({d['reason']})\")
" >> $REPORT_FILE 2>&1

# Kirim ke Telegram
bash ~/JDEQ/bin/notify_telegram.sh "$(head -20 $REPORT_FILE)" 2>/dev/null

# Kirim ke WhatsApp
termux-share -a send -f $REPORT_FILE 2>/dev/null || true

echo "✅ Laporan harian tersimpan: $REPORT_FILE"
REPORT
chmod +x ~/JDEQ/bin/daily_report.sh

# Jadwalkan laporan harian jam 08:00 dan 20:00
(crontab -l 2>/dev/null | grep -v daily_report; echo "0 8,20 * * * bash ~/JDEQ/bin/daily_report.sh") | crontab -
stamp "✅ Laporan harian terjadwal (08:00 & 20:00)"

# ============================================================
# 5. RENDER DASHBOARD (WEB SERVER LOKAL UNTUK APLIKASI ANDROID)
# ============================================================
stamp ""
stamp "===== RENDER DASHBOARD ====="

cat > ~/JDEQ/bin/render_server.py << 'RENDER'
#!/usr/bin/env python3
"""MICO Render Server - Dashboard real-time di browser Android"""
import http.server, json, os, subprocess, sys
from datetime import datetime

PORT = 8083

class RenderHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            html = """<!DOCTYPE html>
<html><head><title>MICO Dashboard</title><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body{font-family:monospace;background:#1a1a2e;color:#e0e0e0;padding:10px}
h1{color:#00ff88}.card{background:#16213e;padding:10px;margin:5px 0;border-radius:8px}
.green{color:#00ff88}.red{color:#ff5555}.yellow{color:#ffaa00}
</style></head><body>
<h1>🖥️ MICO Dashboard</h1>
<div id="data">Memuat...</div>
<script>
async function load(){try{let r=await fetch('/api');let d=await r.json();document.getElementById('data').innerHTML=d.html;}catch(e){document.getElementById('data').innerHTML='Gagal memuat';}}
load();setInterval(load,5000);
</script></body></html>"""
            self.wfile.write(html.encode())
        elif self.path == "/api":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            # Data real-time
            ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
            llm = "✅" if os.popen("pgrep llama-server").read().strip() else "❌"
            ghost = "✅" if os.popen("pgrep -f ghost_relay.py").read().strip() else "❌"
            infinix = "✅" if os.popen("ping -c 1 -W 1 100.103.39.81").read().find("1 received") > -1 else "❌"
            html = f"""
<div class="card">RAM: {ram} MB free</div>
<div class="card">LLM: <span class="{'green' if llm=='✅' else 'red'}">{llm}</span></div>
<div class="card">Ghost: <span class="{'green' if ghost=='✅' else 'red'}">{ghost}</span></div>
<div class="card">Infinix: <span class="{'green' if infinix=='✅' else 'red'}">{infinix}</span></div>
<div class="card">Waktu: {datetime.now().strftime('%H:%M:%S')}</div>
"""
            self.wfile.write(json.dumps({"html": html}).encode())
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    print(f"Render server di http://localhost:{PORT}")
    http.server.HTTPServer(("0.0.0.0", PORT), RenderHandler).serve_forever()
RENDER
chmod +x ~/JDEQ/bin/render_server.py

# Jalankan render server
pkill -f render_server.py 2>/dev/null
nohup python3 ~/JDEQ/bin/render_server.py > /dev/null 2>&1 &
sleep 2
curl -s http://localhost:8083 > /dev/null && stamp "✅ Render server aktif di http://localhost:8083" || stamp "⚠️ Render server gagal"

# ============================================================
# 6. AKTIVASI SEMUA MODUL & CRONJOBS
# ============================================================
stamp ""
stamp "===== AKTIVASI SEMUA MODUL ====="

# Jalankan semua modul inti
bash ~/JDEQ/bin/auto_heal_network.sh >> $LOG 2>&1 &
bash ~/JDEQ/bin/auto_snapshot.sh >> $LOG 2>&1 &
bash ~/JDEQ/bin/health_report.sh >> $LOG 2>&1 &
bash ~/JDEQ/bin/identity_check.sh >> $LOG 2>&1 &
bash ~/JDEQ/bin/decision_audit.sh >> $LOG 2>&1 &
bash ~/JDEQ/bin/auto_heal_cognitive.sh >> $LOG 2>&1 &
bash ~/JDEQ/bin/sync_multi_cloud.sh >> $LOG 2>&1 &

stamp "✅ Semua modul diaktifkan"

# ============================================================
# VERIFIKASI AKHIR
# ============================================================
stamp ""
stamp "============================================"
stamp " VERIFIKASI MULTI-CLOUD & NOTIFIKASI"
stamp "============================================"
echo "📊 Dashboard Render : $(curl -s http://localhost:8083 > /dev/null && echo '✅ AKTIF' || echo '⚠️')" | tee -a $LOG
echo "📱 Notif Telegram  : $(bash ~/JDEQ/bin/notify_telegram.sh 'Test MICO' 2>&1 | tail -1)" | tee -a $LOG
echo "📱 Notif WhatsApp  : $(bash ~/JDEQ/bin/notify_whatsapp.sh 'Test MICO' 2>&1 | tail -1)" | tee -a $LOG
echo "☁️  Multi-Cloud     : $(bash ~/JDEQ/bin/sync_multi_cloud.sh 2>&1 | tail -1)" | tee -a $LOG
echo "🌳 Tree-L Sync     : $(ls ~/JDEQ/TREE_L/ 2>/dev/null | wc -l) folder" | tee -a $LOG
echo "📋 Laporan Harian  : $(bash ~/JDEQ/bin/daily_report.sh 2>&1 | tail -1)" | tee -a $LOG

stamp ""
stamp "============================================"
stamp " BUNDLE MULTI-CLOUD AKTIF"
stamp "  10 Gmail + OneDrive: siap"
stamp "  Tree-L Sync: Infinix + Colab"
stamp "  Notifikasi: Telegram + WhatsApp"
stamp "  Render: http://localhost:8083"
stamp "  Laporan Harian: 08:00 & 20:00"
stamp "============================================"

command -v termux-tts-speak > /dev/null && termux-tts-speak "Multi cloud dan notifikasi aktif. MICO terhubung ke 10 Gmail, OneDrive, dan siap melapor ke Dewan Agen." 2>/dev/null || true
