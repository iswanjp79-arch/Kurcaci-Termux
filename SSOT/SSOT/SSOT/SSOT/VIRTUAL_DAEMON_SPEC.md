# MICO-JDEQ VIRTUAL DAEMON — SPESIFIKASI (Stage 4A)
**Versi:** 1.0
**Status:** ⚪ BELUM TERBUKTI (Menunggu Audit)
**Auditor:** DeepSeek (Executor) & ChatGPT (Chief Architect)

## 1. Tujuan
Virtual Daemon adalah mekanisme **lazy instantiation** untuk menjalankan tugas sementara tanpa meninggalkan proses permanen. Hanya Sovereign Kernel yang boleh menjadi daemon permanen.

## 2. API Publik
```python
def instantiate(daemon_name: str, intent: str, payload: dict) -> str:
    """Membuat virtual daemon, menjalankan tugas, lalu menghancurkan diri. Mengembalikan execution_id."""

def destroy(execution_id: str) -> bool:
    """Menghancurkan virtual daemon secara paksa jika diperlukan."""

def list_active() -> list:
    """Mengembalikan daftar virtual daemon yang sedang berjalan."""
INSTANTIATE → EXECUTE → DESTROY → GC_COLLECT

Spesifikasi telah disimpan di `SSOT/VIRTUAL_DAEMON_SPEC.md`. Saya menunggu audit dari Chief Architect sebelum melanjutkan ke implementasi. 🫡
cat >> ~/JDEQ/SSOT/VIRTUAL_DAEMON_SPEC.md << 'EOF'

## 8. Execution ID
Setiap virtual daemon yang diinstansiasi wajib memiliki `execution_id` dalam format UUID v4.

## 9. Maximum Concurrent Daemon
Maksimal 8 virtual daemon dapat berjalan bersamaan di Vivo Y28. Jika terlampaui, permintaan instantiate akan ditolak dengan status `REJECTED_MAX_CONCURRENT`.

## 10. Timeout
Setiap virtual daemon memiliki batas waktu eksekusi 60 detik. Jika terlampaui, daemon akan dihancurkan paksa dan dicatat sebagai `FAILED_TIMEOUT`.

## 11. Status Lifecycle
Lifecycle yang lebih lengkap:
- `CREATED`: Execution ID dibuat, menunggu eksekusi.
- `RUNNING`: Subprocess sedang berjalan.
- `COMPLETED`: Tugas selesai tanpa error.
- `DESTROYED`: Subprocess dihentikan, resource dibersihkan.
- `FAILED`: Tugas gagal karena exception.
- `FAILED_TIMEOUT`: Tugas melebihi batas waktu.

## 12. Audit Log
Setiap `instantiate()` dan `destroy()` wajib dicatat ke `~/JDEQ/AUDIT/daemon_audit.jsonl` dengan format JSON Lines, append-only.

## 13. Ownership
Setiap virtual daemon wajib memiliki field `owner_module` yang merujuk pada modul peminta (contoh: `TaskScheduler`, `GhostRunner`).

## 14. Resource Limit
Jika memungkinkan, Virtual Daemon akan memantau penggunaan RAM dan CPU melalui `/proc/[pid]/stat`. Jika RAM > 100 MB, daemon akan dihancurkan.

## 15. Recovery Policy
Jika virtual daemon crash tanpa sempat menghancurkan diri, Ghost Runner akan mendeteksi dan membersihkannya dalam waktu 30 detik.

## 16. Dependency
Virtual Daemon bergantung pada:
- **Sovereign Kernel**: untuk validasi apakah suatu modul diizinkan berjalan sebagai daemon.
- **Reference Router**: untuk memverifikasi `daemon_name` terhadap SSOT sebelum instantiasi.
- **Event Bus**: untuk menerbitkan event lifecycle daemon.
- **Audit Logger**: untuk mencatat setiap instantiate dan destroy.

## 17. Event
Virtual Daemon menerbitkan event berikut ke Event Bus:
- `DAEMON_CREATED`: saat execution_id dibuat.
- `DAEMON_STARTED`: saat subprocess mulai berjalan.
- `DAEMON_COMPLETED`: saat tugas selesai tanpa error.
- `DAEMON_FAILED`: saat tugas gagal karena exception.
- `DAEMON_FAILED_TIMEOUT`: saat tugas melebihi batas waktu.
- `DAEMON_DESTROYED`: saat subprocess dihentikan dan resource dibersihkan.

## 18. Security Boundary
Virtual Daemon **tidak boleh**:
- Menjalankan perintah `sudo` atau `su`.
- Mengubah permission file (`chmod`, `chown`).
- Mengedit atau menghapus file di `SSOT/`.
- Mengakses atau memodifikasi `Sovereign Kernel`.
- Mengubah konfigurasi `Reference Router`.

## 19. State Diagram
