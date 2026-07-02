#!/data/data/com.termux/files/usr/bin/bash
LAST_FILE="/data/data/com.termux/files/home/JDEQ/logs/last_notif.txt"
while true; do
    # Tunggu event dari termux-notification-list (dipanggil dari luar)
    # Untuk sementara, kita tetap polling tapi dengan interval lebih panjang 60 detik
    # Nantinya bisa diintegrasikan dengan Tasker via HTTP trigger
    sleep 60
done
