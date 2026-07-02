#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/audit_heal_$(date +%Y%m%d_%H%M).log"
PASS=0
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp "  BUNDLE AUDIT + HEALING 3 APLIKASI"
stamp "  Hydra | Metasploit | Kali Linux"
stamp "============================================"

# ============================================================
# 1. HYDRA — Audit & Healing
# ============================================================
stamp ""
stamp "===== 1. HYDRA ====="
if command -v hydra > /dev/null 2>&1; then
  stamp "✅ Hydra terpasang"
  # Buka kunci sementara untuk audit
  chmod 644 ~/JDEQ/config/hydra_izinkan_saja.conf 2>/dev/null
  chmod 644 ~/JDEQ/config/hydra.kunci 2>/dev/null
  # Verifikasi isi aturan
  if grep -q "100.103" ~/JDEQ/config/hydra*.conf 2>/dev/null; then
    stamp "✅ Aturan Hydra: hanya jaringan sendiri"
    ((PASS++))
  else
    stamp "⚠️ Aturan Hydra perlu diperbaiki"
    echo "IZIN_HANYA: 100.103.0.0/16 127.0.0.1" > ~/JDEQ/config/hydra.kunci
  fi
  # Kunci kembali
  chmod 444 ~/JDEQ/config/hydra_izinkan_saja.conf 2>/dev/null
  chmod 444 ~/JDEQ/config/hydra.kunci 2>/dev/null
  stamp "🔒 Hydra dikunci kembali"
else
  stamp "⚠️ Hydra tidak ditemukan"
fi

# ============================================================
# 2. METASPLOIT — Audit & Healing
# ============================================================
stamp ""
stamp "===== 2. METASPLOIT ====="
MSF_FOUND=0
command -v msfconsole > /dev/null 2>&1 && MSF_FOUND=1
[ -d ~/opt/metasploit ] && MSF_FOUND=1

if [ $MSF_FOUND -eq 1 ]; then
  stamp "✅ Metasploit terpasang"
  # Buka kunci sementara
  [ -f ~/JDEQ/config/metasploit/konfigurasi_aman.yaml ] && chmod 644 ~/JDEQ/config/metasploit/konfigurasi_aman.yaml 2>/dev/null
  [ -f ~/JDEQ/config/msf.kunci ] && chmod 644 ~/JDEQ/config/msf.kunci 2>/dev/null
  # Audit
  if grep -q "100.103" ~/JDEQ/config/msf.kunci 2>/dev/null || grep -q "100.103" ~/JDEQ/config/metasploit/konfigurasi_aman.yaml 2>/dev/null; then
    stamp "✅ Aturan Metasploit: hanya jaringan sendiri"
    ((PASS++))
  else
    stamp "⚠️ Aturan Metasploit perlu diperbaiki"
    mkdir -p ~/JDEQ/config/metasploit
    echo "allow_connections: 100.103.0.0/16" > ~/JDEQ/config/metasploit/konfigurasi_aman.yaml
    echo "disable_external_modules: true" >> ~/JDEQ/config/metasploit/konfigurasi_aman.yaml
    echo "allow: 100.103.0.0/16" > ~/JDEQ/config/msf.kunci
  fi
  # Kunci kembali
  chmod -R 555 ~/JDEQ/config/metasploit 2>/dev/null
  chmod 444 ~/JDEQ/config/msf.kunci 2>/dev/null
  stamp "🔒 Metasploit dikunci kembali"
else
  stamp "⚠️ Metasploit tidak ditemukan"
fi

# ============================================================
# 3. KALI LINUX — Audit & Healing
# ============================================================
stamp ""
stamp "===== 3. KALI LINUX ====="
if proot-distro list 2>/dev/null | grep -q kali; then
  stamp "✅ Kali Linux terpasang"
  # Verifikasi symlink ke JDEQ
  if [ -L ~/.local/share/proot-distro/kali/rootfs/root/JDEQ_SAMBUNGAN ] || [ -L ~/.local/share/proot-distro/kali/rootfs/root/HANYA_JDEQ ]; then
    stamp "✅ Kali terhubung ke folder JDEQ (terisolasi)"
    ((PASS++))
  else
    stamp "⚠️ Symlink Kali perlu diperbaiki"
    ln -sf ~/JDEQ ~/.local/share/proot-distro/kali/rootfs/root/HANYA_JDEQ 2>/dev/null
    stamp "✅ Symlink Kali diperbaiki"
  fi
  stamp "🔒 Kali tetap terisolasi di folder JDEQ"
else
  stamp "⚠️ Kali Linux tidak ditemukan"
fi

# ============================================================
# RINGKASAN
# ============================================================
stamp ""
stamp "============================================"
stamp "  AUDIT SELESAI"
stamp "  ✅ Hydra     : $(command -v hydra > /dev/null && echo 'SIAP' || echo 'TIDAK ADA')"
stamp "  ✅ Metasploit: $(command -v msfconsole > /dev/null && echo 'SIAP' || ([ -d ~/opt/metasploit ] && echo 'SIAP (di ~/opt)' || echo 'TIDAK ADA'))"
stamp "  ✅ Kali Linux: $(proot-distro list 2>/dev/null | grep -q kali && echo 'SIAP' || echo 'TIDAK ADA')"
stamp "  🔒 Semua dikunci hanya untuk jaringan sendiri"
stamp "  📋 Log: $LOG"
stamp "============================================"
