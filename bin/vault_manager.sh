#!/data/data/com.termux/files/usr/bin/sh
# SISTEM VAULT JARVIS • ISWANJP79 • KEAMANAN TINGGI
# Lokasi Simpan: ~/JDEQ/vault/ & G04/EKOSISTEM_DIGITAL/

# 📌 ATURAN PENGGUNAAN:
# !vault LIST       → Lihat daftar semua platform
# !vault GET NAMA   → Buka kunci platform
# !vault ADD NAMA   → Masukkan kunci baru

ACTION=$1
INPUT=$2
VAULT_PATH="/data/data/com.termux/files/home/JDEQ/vault"
PASS_KEY="JARVIS_JDEQ_2026_AMAN"  # Kunci Utama Enkripsi (Bisa diubah nanti)

if [ "$ACTION" == "LIST" ]; then
    echo "🔐 DAFTAR BRANKAS DIGITAL ISWANJP79:"
    ls $VAULT_PATH/*.enc 2>/dev/null | sed 's/.*\///' | sed 's/.enc//g'
    echo "✅ Selesai"

elif [ "$ACTION" == "GET" ]; then
    if [ -f "$VAULT_PATH/$INPUT.enc" ]; then
        echo "🔓 MEMBUKA BRANKAS: $INPUT ..."
        openssl aes-256-cbc -d -a -pbkdf2 -in "$VAULT_PATH/$INPUT.enc" -pass pass:$VAULT_PASS
        echo "\n⚠️ Hapus layar dalam 10 detik..."
        sleep 10
        clear
    else
        echo "❌ Data untuk '$INPUT' TIDAK DITEMUKAN!"
    fi

elif [ "$ACTION" == "ADD" ]; then
    echo "✍️ MASUKKAN DATA UNTUK: $INPUT"
    echo "Ketik semua kunci/api di bawah, selesai tekan ENTER lalu tekan CTRL+D:"
    cat > /tmp/raw_data.tmp
    openssl aes-256-cbc -a -pbkdf2 -salt -out "$VAULT_PATH/$INPUT.enc" -pass pass:$VAULT_PASS < /tmp/raw_data.tmp
    rm -f /tmp/raw_data.tmp
    # Salin cadangan ke Google Drive G04 (Otak Pusat)
    cp "$VAULT_PATH/$INPUT.enc" ~/storage/shared/CLOUD_G04/EKOSISTEM_DIGITAL/VAULT_AMAN/
    echo "✅ ✅ BERHASIL DISIMPAN & TERENKRIPSI! ✅ ✅"
    echo "📌 Cadangan aman di: G04/EKOSISTEM_DIGITAL/VAULT_AMAN/"

else
    echo "📌 PENGGUNAAN PERINTAH:"
    echo "!vault LIST          → Lihat daftar"
    echo "!vault GET NAMA      → Ambil kunci"
    echo "!vault ADD NAMA      → Tambah kunci baru"
fi
