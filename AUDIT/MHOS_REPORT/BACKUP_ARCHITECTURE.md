# Backup Architecture (3-2-1)
- **3 salinan:** Termux (utama), Internal Storage (manual), Cloud (rclone)
- **2 media berbeda:** penyimpanan internal ponsel + Google Drive
- **1 lokasi cloud:** rclone remote BRANKAS_UTAMA
- **Checksum:** SHA256 setiap backup
- **Rotasi:** snapshots harian (jika diaktifkan)
