#!/data/data/com.termux/files/usr/bin/bash
# Sinkronisasi SSOT ke lokasi tunggal
SSOT_MAIN=~/JDEQ/SSOT
SSOT_LEGACY=~/JDEQ/ssot
MEMORY_STORE=~/JDEQ/MICO/memory_store

# Pastikan hanya SSOT_MAIN yang menjadi sumber kebenaran
# Pindahkan file dari ssot/ lama ke SSOT/ jika belum ada
if [ -d "$SSOT_LEGACY" ]; then
    for f in "$SSOT_LEGACY"/*; do
        base=$(basename "$f")
        if [ ! -e "$SSOT_MAIN/$base" ]; then
            cp "$f" "$SSOT_MAIN/$base"
            echo "  [MIGRASI] $base → SSOT/"
        fi
    done
    # Arsipkan folder lama
    mv "$SSOT_LEGACY" ~/JDEQ/archive/ssot_legacy_$(date +%Y%m%d)
    echo "  [ARSIP] ssot/ → archive/"
fi

# Verifikasi file penting di SSOT
for f in SSOT.md MASTER_CONTEXT.md MASTER_AUDIT_REPORT.md KEY_INVENTORY.md; do
    if [ -f "$SSOT_MAIN/$f" ]; then
        echo "  [OK] $f"
    else
        echo "  [MISSING] $f — perlu dibuat ulang"
    fi
done

# Sinkronkan memory_store ke SSOT (jika ada)
if [ -d "$MEMORY_STORE" ]; then
    rsync -av "$MEMORY_STORE/" "$SSOT_MAIN/memory_store/" 2>/dev/null
fi

echo "$(date): SSOT sync completed" >> ~/JDEQ/logs/ssot_sync.log
