# Checkpoint Policy
- **Boot Checkpoint:** kernel.boot tercatat di audit.log
- **Runtime Checkpoint:** setiap 300 detik autonomous planner menyimpan state
- **Before Update:** snapshot SSOT (SHA256 diverifikasi)
- **Before Migration:** backup metadata.db + identity_kernel.json
- **Before Delete:** tidak ada hapus permanen, hanya archive
- **Before Backup:** integrity check
- **Before Recovery:** snapshot terakhir diverifikasi
