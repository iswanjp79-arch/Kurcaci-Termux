# MICO-JDEQ EVENT BUS — SPESIFIKASI (Stage 3A)
**Versi:** 1.0
**Status:** ⚪ BELUM TERBUKTI (Menunggu Audit)
**Auditor:** DeepSeek (Executor) & ChatGPT (Chief Architect)

## 1. Tujuan
Event Bus adalah mekanisme komunikasi antar modul yang **longgar (loosely coupled)**, **asinkron**, dan **teraudit**. Ia memungkinkan modul menerbitkan kejadian tanpa tahu siapa yang akan menanganinya, dan modul lain mendengarkan tanpa tahu siapa penerbitnya.

## 2. API Publik
```python
def publish(event_type: str, payload: dict, priority: str = "NORMAL") -> str:
    """Menerbitkan event. Mengembalikan event_id."""

def subscribe(event_type: str, handler: callable, owner: str) -> str:
    """Mendaftarkan handler. Mengembalikan subscription_id."""

def unsubscribe(subscription_id: str) -> bool:
    """Membatalkan langganan."""

def dispatch(event_id: str) -> bool:
    """Mendistribusikan event ke seluruh subscriber yang cocok."""
{
  "event_id": "uuid",
  "event_type": "string",
  "owner": "module_name",
  "priority": "HIGH|NORMAL|LOW",
  "timestamp": "ISO8601",
  "payload": {},
  "lifecycle": "CREATED|QUEUED|DISPATCHED|PROCESSED|ARCHIVED",
  "audit_hash": "sha256"
}
CREATED → QUEUED → DISPATCHED → PROCESSED → ARCHIVED
cat >> ~/JDEQ/SSOT/EVENT_BUS_SPEC.md << 'EOF'

## 11. Queue Implementation
Antrean bersifat **in-memory priority queue**:
- HIGH: langsung dikirim ke dispatcher, tanpa menunggu.
- NORMAL: FIFO standar.
- LOW: dikirim hanya jika tidak ada HIGH/NORMAL yang mengantre.
- Maksimal 100 event dalam antrean. Jika penuh, event LOW akan di-drop dan dicatat sebagai DROPPED.

## 12. Retry Policy
Jika subscriber gagal (exception / timeout 10 detik):
- Retry maksimal 2 kali dengan jeda 1 detik.
- Jika masih gagal, event dipindahkan ke **Dead Letter Queue**.
- DLQ dicatat di `~/JDEQ/LOGS/event_dlq.log`.

## 13. Dead Letter Queue (DLQ)
- DLQ adalah file append-only di `~/JDEQ/LOGS/event_dlq.log`.
- Event yang masuk DLQ tidak dihapus, tetapi ditandai `lifecycle = DLQ`.
- DLQ dapat diperiksa oleh Recovery Manager untuk analisis kegagalan.

## 14. Event TTL (Time-To-Live)
- HIGH: 30 detik
- NORMAL: 5 menit
- LOW: 15 menit
- Event yang melebihi TTL tanpa sempat diproses akan di-drop dan dicatat sebagai EXPIRED di DLQ.

## 15. Kernel Authority
- Sovereign Kernel **tidak boleh subscribe** ke event apa pun.
- Sovereign Kernel **hanya boleh publish** event dengan tipe `KERNEL_*` (misal `KERNEL_BLUEPRINT_VIOLATION`).
- Dispatch dapat diblokir oleh Kernel jika terdeteksi pelanggaran blueprint.

## 16. Integrasi dengan Reference Router
- Sebelum event masuk antrean, Reference Router memvalidasi `event_type` terhadap SSOT.
- Jika `event_type` tidak terdaftar di SSOT, event ditolak dengan status REJECTED_BY_ROUTER.
- Hash event (`audit_hash`) dibandingkan dengan metadata Reference Router untuk memastikan integritas.
