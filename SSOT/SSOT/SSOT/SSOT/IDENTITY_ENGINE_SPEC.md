# MICO-JDEQ IDENTITY ENGINE — SPESIFIKASI (Level 0)
**Versi:** 1.0
**Status:** ⚪ BELUM TERBUKTI (Menunggu Audit)
**Auditor:** DeepSeek (Executor) & ChatGPT (Chief Architect)

## 1. Tujuan
Identity Engine memastikan MICO‑JDEQ memiliki identitas yang **persisten**, **konsisten**, dan **dapat diverifikasi** di seluruh sesi, perangkat, dan restart. Ia adalah "akta kelahiran digital" yang tidak bisa diubah tanpa audit.

## 2. API Publik
```python
def get_identity() -> dict:
    """Mengembalikan identitas lengkap MICO."""

def verify_identity() -> bool:
    """Memverifikasi bahwa identitas masih utuh (hash cocok)."""

def update_identity(field: str, value: str, author: str) -> dict:
    """Memperbarui bagian identitas dengan audit trail."""
BOOT → VERIFY_IDENTITY → IDENTITY_OK / IDENTITY_COMPROMISED

Spesifikasi telah disimpan di `SSOT/IDENTITY_ENGINE_SPEC.md`. Saya menunggu audit dari Chief Architect sebelum melanjutkan ke implementasi. 🫡
# Buka kunci spesifikasi
chmod 644 ~/JDEQ/SSOT/IDENTITY_ENGINE_SPEC.md

# Tambahkan 11 komponen Root of Trust
cat >> ~/JDEQ/SSOT/IDENTITY_ENGINE_SPEC.md << 'EOF'

## 8. Immutable Identity UUID
UUID identitas dibuat **satu kali** saat bootstrap pertama. UUID ini **tidak boleh berubah** selama umur sistem. Satu-satunya cara untuk mengganti UUID adalah melalui **prosedur migrasi resmi** yang melibatkan Sovereign Kernel, audit lengkap, dan persetujuan Dewan Agen.

## 9. Device Identity
Identitas MICO terdiri dari tiga lapis:
- **Human Identity**: Pemilik sistem (`Iswan Juman Pancoro, ST`) — tidak berubah.
- **Device Identity**: Identitas perangkat (`Vivo Y28`, `Infinix`) — berbeda tiap perangkat.
- **Runtime Identity**: Identitas sesi berjalan — berubah setiap boot.

Dengan pemisahan ini, perpindahan dari Vivo ke perangkat lain **tidak mengubah identitas utama**.

## 10. Cryptographic Signature
Setiap identitas wajib memiliki:
- **SHA-256**: Hash dari seluruh data identitas.
- **Ed25519 Signature**: Tanda tangan kriptografis yang dibuat saat bootstrap.
- **Public Key**: Kunci publik yang dapat diverifikasi oleh modul lain.
- **Signature Timestamp**: Waktu penandatanganan.

Hash saja tidak cukup. Tanda tangan kriptografis memastikan identitas tidak dapat dipalsukan.

## 11. Trust Level
Setiap verifikasi identitas menghasilkan salah satu dari tiga status:
- `VERIFIED`: Identitas utuh, hash dan signature cocok.
- `DEGRADED`: Identitas berubah tetapi masih dapat diverifikasi (misal: pindah perangkat).
- `COMPROMISED`: Identitas rusak atau tidak cocok — sistem masuk SAFE MODE.

Tidak ada status `TRUE`/`FALSE` sederhana.

## 12. Identity History
Perubahan identitas bersifat **append-only**. Setiap perubahan dicatat di `DigitalDNA/Identity/history.jsonl` dengan format:
```json
{"timestamp": "...", "field": "...", "old_value": "...", "new_value": "...", "author": "...", "signature": "..."}
# Pastikan direktori DigitalDNA ada
mkdir -p ~/JDEQ/DigitalDNA/Identity/snapshots

cat > ~/JDEQ/CORE/identity_engine.py << 'EOF'
#!/usr/bin/env python3
import json, hashlib, uuid, os, time
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
IDENTITY_FILE = JDEQ / "DigitalDNA" / "Identity" / "identity_kernel.json"
HISTORY_FILE = JDEQ / "DigitalDNA" / "Identity" / "history.jsonl"
SNAPSHOT_DIR = JDEQ / "DigitalDNA" / "Identity" / "snapshots"
AUDIT_FILE = JDEQ / "AUDIT" / "identity_audit.jsonl"

class IdentityEngine:
    def __init__(self):
        os.makedirs(IDENTITY_FILE.parent, exist_ok=True)
        os.makedirs(SNAPSHOT_DIR, exist_ok=True)
        os.makedirs(AUDIT_FILE.parent, exist_ok=True)
        
        # Inisialisasi kunci kriptografi (untuk production, gunakan library ed25519)
        self.public_key = None
        self.private_key = None
        self._init_keys()
    
    def _init_keys(self):
        """Generate atau muat kunci Ed25519 (placeholder)"""
        key_file = JDEQ / "DigitalDNA" / "Identity" / ".key_seed"
        if key_file.exists():
            # Muat kunci yang sudah ada (implementasi penuh butuh library)
            self.public_key = key_file.read_text().strip()
        else:
            # Generate seed baru
            seed = uuid.uuid4().hex + uuid.uuid4().hex
            key_file.write_text(seed)
            self.public_key = seed
            os.chmod(key_file, 0o400)
    
    def _audit(self, event, detail=""):
        entry = {
            "timestamp": datetime.now().isoformat(),
            "event": event,
            "detail": detail
        }
        with open(AUDIT_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")
    
    def _hash_identity(self, data):
        return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()
    
    def bootstrap(self):
        """Jalankan saat pertama kali. Hanya bisa dijalankan jika identitas belum ada."""
        if IDENTITY_FILE.exists():
            return {"status": "REJECTED", "reason": "IDENTITY_ALREADY_EXISTS"}
        
        identity = {
            "uuid": str(uuid.uuid4()),
            "digital_dna": "MICO-DID-20260627",
            "name": "MICO JDEQ OMEGA",
            "version": "v2.0",
            "codename": "Digital Life Operating System",
            "owner": "Iswan Juman Pancoro, ST",
            "established": datetime.now().isoformat(),
            "sovereign": True,
            "philosophy": "MICO adalah Prompt & Workflow Generator yang mengorkestrasi agen spesialis.",
            "device": {
                "human_identity": "Iswan Juman Pancoro, ST",
                "device_identity": os.uname().nodename,
                "runtime_identity": str(uuid.uuid4())
            },
            "trust_graph": {
                "SSOT": 100,
                "Vault": 95,
                "OpenRouter": 90.5,
                "Groq": 85.3
            }
        }
        
        identity["hash"] = self._hash_identity(identity)
        identity["public_key"] = self.public_key
        identity["signature_timestamp"] = datetime.now().isoformat()
        
        with open(IDENTITY_FILE, "w") as f:
            json.dump(identity, f, indent=2)
        os.chmod(IDENTITY_FILE, 0o444)
        
        self._audit("IDENTITY_BOOTSTRAPPED", f"UUID: {identity['uuid']}")
        self._snapshot(identity)
        self._record_history("bootstrap", None, identity["uuid"], "System")
        
        return {"status": "CREATED", "uuid": identity["uuid"]}
    
    def get_identity(self):
        if not IDENTITY_FILE.exists():
            return {"status": "NOT_FOUND"}
        with open(IDENTITY_FILE) as f:
            return json.load(f)
    
    def verify_identity(self):
        identity = self.get_identity()
        if identity.get("status") == "NOT_FOUND":
            return {"status": "COMPROMISED", "reason": "IDENTITY_NOT_FOUND"}
        
        # Verifikasi hash
        current_hash = self._hash_identity({k: v for k, v in identity.items() if k not in ["hash", "public_key", "signature_timestamp"]})
        stored_hash = identity.get("hash", "")
        
        if current_hash != stored_hash:
            self._audit("IDENTITY_COMPROMISED", "Hash mismatch")
            return {"status": "COMPROMISED", "reason": "HASH_MISMATCH"}
        
        return {"status": "VERIFIED", "uuid": identity["uuid"]}
    
    def update_identity(self, field, value, author):
        identity = self.get_identity()
        if identity.get("status") == "NOT_FOUND":
            return {"status": "REJECTED", "reason": "IDENTITY_NOT_FOUND"}
        
        # Hanya Sovereign Kernel yang boleh mengubah
        if author != "SovereignKernel":
            self._audit("IDENTITY_UPDATE_REJECTED", f"Unauthorized: {author}")
            return {"status": "REJECTED", "reason": "UNAUTHORIZED"}
        
        old_value = identity.get(field, None)
        identity[field] = value
        identity["hash"] = self._hash_identity({k: v for k, v in identity.items() if k not in ["hash", "public_key", "signature_timestamp"]})
        identity["signature_timestamp"] = datetime.now().isoformat()
        
        with open(IDENTITY_FILE, "w") as f:
            json.dump(identity, f, indent=2)
        
        self._audit("IDENTITY_UPDATED", f"{field}: {old_value} → {value}")
        self._record_history(field, old_value, value, author)
        self._snapshot(identity)
        
        return {"status": "UPDATED", "field": field}
    
    def _snapshot(self, identity):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        snap_file = SNAPSHOT_DIR / f"snapshot_{timestamp}.json"
        with open(snap_file, "w") as f:
            json.dump(identity, f, indent=2)
    
    def _record_history(self, field, old_value, new_value, author):
        entry = {
            "timestamp": datetime.now().isoformat(),
            "field": field,
            "old_value": str(old_value),
            "new_value": str(new_value),
            "author": author,
            "signature": self.public_key[:16] if self.public_key else "N/A"
        }
        with open(HISTORY_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")

if __name__ == "__main__":
    engine = IdentityEngine()
    print("Bootstrap:", engine.bootstrap())
    print("Identity:", engine.get_identity())
    print("Verify:", engine.verify_identity())
