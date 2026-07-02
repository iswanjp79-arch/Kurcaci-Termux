#!/usr/bin/env python3
"""JDEQ V7 — Version Validator. Metadata minimal: id, version, timestamp, hash, author, verified, source, priority"""
import json, os, sqlite3
from datetime import datetime
from pathlib import Path

METADATA_DB = Path.home() / "JDEQ/RUNTIME/metadata.db"

class VersionValidator:
    def __init__(self):
        self.conn = sqlite3.connect(str(METADATA_DB))
    
    def validate(self, doc_id, version):
        """Validasi versi dokumen. Jika versi lebih lama → REJECT"""
        row = self.conn.execute(
            "SELECT version, timestamp, hash, author, verified, source, priority FROM metadata WHERE id = ?",
            (doc_id,)
        ).fetchone()
        
        if not row:
            return {"status": "REJECT", "reason": "METADATA_NOT_FOUND"}
        
        stored_version = row[0]
        # Bandingkan versi (format: major.minor.patch)
        try:
            stored_parts = [int(x) for x in stored_version.split(".")]
            new_parts = [int(x) for x in version.split(".")]
            
            for s, n in zip(stored_parts, new_parts):
                if n < s:
                    return {"status": "REJECT", "reason": f"VERSION_OLDER: {version} < {stored_version}"}
                elif n > s:
                    break
        except:
            pass
        
        return {
            "status": "APPROVED",
            "metadata": {
                "id": doc_id, "version": stored_version,
                "timestamp": row[1], "hash": row[2][:16],
                "author": row[3], "verified": bool(row[4]),
                "source": row[5], "priority": row[6]
            }
        }

if __name__ == "__main__":
    validator = VersionValidator()
    result = validator.validate("BLUEPRINT_V7", "7.0.0")
    print(f"✅ Version Validator: {json.dumps(result, indent=2)}")
