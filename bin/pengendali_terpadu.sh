#!/bin/bash
# ============================================================
# PENGENDALI SATU ENTITAS — Context Builder & State Manager
# ============================================================
ENTITAS_KUNCI="JDEQ-7-SINGLE-ENTITY-2026-07-02"
BERKAS_PUSAT=~/JDEQ/SSOT/ENTITAS_TUNGGAL.json
CATATAN_PUSAT=~/JDEQ/AUDIT/SEMUA_INTERAKSI.log

# 1. Cocokkan Identitas
KUNCI_DIBACA=$(grep KUNCI_TANDA "$BERKAS_PUSAT" | cut -d'"' -f4)
if [ "$KUNCI_DIBACA" != "$ENTITAS_KUNCI" ]; then
  echo "❌ DILARANG: Bukan entitas sah — hentikan sesi"
  exit 1
fi

# 2. Catat Semua Ke Satu Tempat
echo "[$(date)] AGEN:${1:-TANPA_NAMA} | PERANGKAT:$(hostname) | PESAN:${2:-KOSONG}" >> "$CATATAN_PUSAT"

# 3. Keluarkan Acuan Seragam & Konteks
echo "=== ACUAN ENTITAS TUNGGAL ==="
echo "Nama: $(grep IDENTITAS_UTAMA "$BERKAS_PUSAT" | cut -d'"' -f4)"
echo "Aturan Pokok: Sumber kebenaran tunggal — tak ada beda ruang obrolan"
echo "=============================="
