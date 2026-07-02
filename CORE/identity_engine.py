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
        self.public_key = None
        self._init_keys()

    def _init_keys(self):
        key_file = JDEQ / "DigitalDNA" / "Identity" / ".key_seed"
        if key_file.exists():
            self.public_key = key_file.read_text().strip()
        else:
            seed = uuid.uuid4().hex + uuid.uuid4().hex
            key_file.write_text(seed)
            self.public_key = seed
            os.chmod(key_file, 0o400)

    def _audit(self, event, detail=""):
        entry = {"timestamp": datetime.now().isoformat(), "event": event, "detail": detail}
        with open(AUDIT_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")

    def _hash_identity(self, data):
        return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()

    def bootstrap(self):
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
            "trust_graph": {"SSOT": 100, "Vault": 95, "OpenRouter": 90.5, "Groq": 85.3}
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
        current_hash = self._hash_identity({k: v for k, v in identity.items() if k not in ["hash", "public_key", "signature_timestamp"]})
        if current_hash != identity.get("hash", ""):
            self._audit("IDENTITY_COMPROMISED", "Hash mismatch")
            return {"status": "COMPROMISED", "reason": "HASH_MISMATCH"}
        return {"status": "VERIFIED", "uuid": identity["uuid"]}

    def update_identity(self, field, value, author):
        if author != "SovereignKernel":
            self._audit("IDENTITY_UPDATE_REJECTED", f"Unauthorized: {author}")
            return {"status": "REJECTED", "reason": "UNAUTHORIZED"}
        identity = self.get_identity()
        if identity.get("status") == "NOT_FOUND":
            return {"status": "REJECTED", "reason": "IDENTITY_NOT_FOUND"}
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
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(SNAPSHOT_DIR / f"snapshot_{ts}.json", "w") as f:
            json.dump(identity, f, indent=2)

    def _record_history(self, field, old, new, author):
        entry = {"timestamp": datetime.now().isoformat(), "field": field, "old_value": str(old), "new_value": str(new), "author": author, "signature": self.public_key[:16] if self.public_key else "N/A"}
        with open(HISTORY_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")

if __name__ == "__main__":
    ie = IdentityEngine()
    print("Bootstrap:", ie.bootstrap())
    print("Identity:", ie.get_identity())
    print("Verify:", ie.verify_identity())
