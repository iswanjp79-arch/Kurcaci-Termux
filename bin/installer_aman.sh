#!/bin/bash
set -e
echo "🔧 MEMULAI INSTALASI AMAN..."
for LANGKAH in "IDENTITAS" "DETEKTOR" "AUTO_CABUT" "RECOVERY"; do
  case $LANGKAH in
    "IDENTITAS") FILE=~/JDEQ/SECURITY/IDENTITAS_ANTI_MALING.json ;;
    "DETEKTOR") FILE=~/JDEQ/bin/detektor_asing.sh ;;
    "AUTO_CABUT") FILE=~/JDEQ/bin/auto_cabut.sh ;;
    "RECOVERY") FILE=~/JDEQ/bin/recovery_hp_baru.sh ;;
  esac
  if [ -f "$FILE" ]; then
    echo "   ✅ $LANGKAH OK"
  else
    echo "   ❌ $LANGKAH GAGAL — instalasi DIHENTIKAN"
    exit 1
  fi
done
echo "✅ SEMUA LANGKAH BERHASIL"
