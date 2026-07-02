#!/bin/bash
# Verifikasi akses ke semua remote rclone

REMOTES="G01 G02 G03 G04 G05 G06 G07 G08 G09 G10 Mega01 proton01 ONERINA"
echo "============================================================"
echo "  VERIFIKASI REMOTE RCLONE – $(date)"
echo "============================================================"
for R in $REMOTES; do
  echo -n "Cek $R ... "
  if rclone lsd "$R:" 2>/dev/null | head -1 &> /dev/null; then
    echo "✅ OK"
  else
    echo "❌ GAGAL (mungkin token expired atau remote tidak ada)"
  fi
done
echo "============================================================"
