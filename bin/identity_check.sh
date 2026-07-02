#!/data/data/com.termux/files/usr/bin/bash
# Pastikan SSOT tidak berubah
if [ -f ~/JDEQ/HASH_SEAL/integrity.sha256 ]; then
  sha256sum -c ~/JDEQ/HASH_SEAL/integrity.sha256 > /dev/null 2>&1 && \
    echo "[$(date)] ✅ Identitas MICO UTUH" >> ~/JDEQ/logs/identity.log || \
    echo "[$(date)] 🚨 PERINGATAN: SSOT BERUBAH!" >> ~/JDEQ/logs/identity.log
fi
