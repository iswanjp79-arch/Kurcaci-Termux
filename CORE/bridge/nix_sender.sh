#!/bin/bash
# Kirim perintah dari MICO ke Nix via shared folder
NIX_DIR=~/storage/shared/NixBridge
mkdir -p "$NIX_DIR"

PERINTAH="$*"
if [ -z "$PERINTAH" ]; then
  echo "Pemakaian: nix_sender.sh <perintah>"
  exit 1
fi

# Tulis perintah ke file task
echo "$PERINTAH" > "$NIX_DIR/task.txt"
echo "Terkirim: $PERINTAH"

# Tunggu jawaban (maks 30 detik)
for i in $(seq 1 15); do
  if [ -f "$NIX_DIR/result.txt" ]; then
    echo "Hasil dari Nix:"
    cat "$NIX_DIR/result.txt"
    rm "$NIX_DIR/result.txt" 2>/dev/null
    break
  fi
  sleep 2
done
