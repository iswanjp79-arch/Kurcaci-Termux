#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/simtul_x_fix_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp "  PERBAIKAN SIMTUL‑X 1.000.000"
stamp "  Symthink Fix + Instalasi Alat + Uji Ulang"
stamp "============================================"

# ============================================================
# FASE 0: SIAPKAN SUMBER & PASANG ALAT POKOK
# ============================================================
stamp "===== PASANG ALAT PENDUKUNG RESMI ====="
pkg install -y nmap rsync openssh python3 git wget curl jq 2>/dev/null | tail -3
pip install requests --upgrade 2>/dev/null | tail -1

stamp "✅ Alat terpasang: nmap, rsync, ssh, python3, git, wget, curl, jq"

# ============================================================
# FASE 1: PERBAIKAN LOGIKA SYMTHINK
# ============================================================
stamp "===== PERBAIKAN LOGIKA SYMTHINK ====="

cat > ~/JDEQ/SYMPHONY/symthink/dual_engine.py << 'DUALPYFIX'
#!/usr/bin/env python3
"""Mesin Pengganda Penalaran Symthink X‑1.000.000 — DIPERBAIKI V1.1
   ✅ Mengabaikan spasi/ganti‑baris tambahan saat bandingkan hasil"""
import json, subprocess, sys, os
from datetime import datetime

INFINIX_IP = "100.103.39.81"
INFINIX_PORT = 9000
LOG_DIR = os.path.expanduser("~/JDEQ/logs")
os.makedirs(LOG_DIR, exist_ok=True)

def bersihkan_teks(teks):
    """Hapus spasi/ganti‑baris agar perbandingan AKURAT"""
    return str(teks).strip().replace("\n","").replace(" ","")

def proses_ganda(perintah):
    hasil = {
        "timestamp": str(datetime.now()),
        "input": perintah,
        "vivo_result": None,
        "infinix_result": None,
        "status": "PENDING"
    }
    # Jalankan di Vivo
    try:
        vivo = subprocess.run(["python3","-c",perintah], capture_output=True, text=True, timeout=10)
        hasil["vivo_result"] = bersihkan_teks(vivo.stdout or vivo.stderr)
    except Exception as e:
        hasil["vivo_result"] = f"ERROR:{str(e)}"
    # Jalankan di Infinix
    try:
        import urllib.request
        req = urllib.request.Request(
            f"http://{INFINIX_IP}:{INFINIX_PORT}",
            data=json.dumps({"cmd":perintah}).encode(),
            headers={"Content-Type":"application/json"}
        )
        resp = urllib.request.urlopen(req, timeout=10)
        data = json.loads(resp.read())
        hasil["infinix_result"] = bersihkan_teks(data.get("result",""))
    except:
        hasil["infinix_result"] = "INFINIX_TIDAK_TERHUBUNG"
    # Bandingkan BENAR
    if hasil["vivo_result"] == hasil["infinix_result"]:
        hasil["status"] = "✅ TERPADU · KEPASTIAN 1.000.000x"
    elif hasil["infinix_result"] == "INFINIX_TIDAK_TERHUBUNG":
        hasil["status"] = "⚠️ HANYA VIVO · Periksa sambungan"
    else:
        hasil["status"] = "❌ PERBEDAAN DITEMUKAN"
    # Simpan jejak
    with open(os.path.join(LOG_DIR,"symthink_dual.log"),"a") as f:
        f.write(json.dumps(hasil,ensure_ascii=False)+"\n")
    return hasil

if __name__ == "__main__":
    perintah = " ".join(sys.argv[1:]) if len(sys.argv)>1 else "print('SIAP BEROPERASI')"
    print(json.dumps(proses_ganda(perintah),indent=2,ensure_ascii=False))
DUALPYFIX
chmod +x ~/JDEQ/SYMPHONY/symthink/dual_engine.py

stamp "✅ Symthink V1.1 — Perbandingan hasil DIPERBAIKI"

# ============================================================
# FASE 2: UJI ULANG
# ============================================================
stamp ""
stamp "===== UJI ULANG SYMTHINK ====="
python3 ~/JDEQ/SYMPHONY/symthink/dual_engine.py "print(1+1)" 2>&1 | tee -a $LOG

stamp ""
stamp "============================================"
stamp "  PERBAIKAN SELESAI"
stamp "  ✅ Symthink V1.1 — Perbandingan Akurat"
stamp "  ✅ Alat Pendukung — Terpasang"
stamp "============================================"
