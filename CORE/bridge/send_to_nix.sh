#!/data/data/com.termux/files/usr/bin/bash
# Kirim perintah dari MICO ke Nix via bridge permanen
PERINTAH="$*"
if [ -z "$PERINTAH" ]; then
    echo "Pemakaian: send_to_nix.sh <perintah>"
    exit 1
fi

# Tulis perintah ke file yang dimonitor bridge service
echo "$PERINTAH" > ~/JDEQ/CORE_BRIDGE/messages/to_nix.txt
echo "Perintah terkirim ke Nix: $PERINTAH"

# Tunggu jawaban (maks 30 detik)
for i in $(seq 1 15); do
    if [ -f ~/JDEQ/CORE_BRIDGE/messages/from_nix.txt ]; then
        echo "Hasil dari Nix:"
        cat ~/JDEQ/CORE_BRIDGE/messages/from_nix.txt
        rm ~/JDEQ/CORE_BRIDGE/messages/from_nix.txt 2>/dev/null
        break
    fi
    sleep 2
done
