import json, hashlib, os, sqlite3
from datetime import datetime
from pathlib import Path

SSOT_PATH = Path.home() / "JDEQ/SSOT"
METADATA_DB = Path.home() / "JDEQ/RUNTIME/metadata.db"
AUDIT_LOG = Path.home() / "JDEQ/logs/reference_audit.jsonl"
os.makedirs(SSOT_PATH, exist_ok=True)
os.makedirs(AUDIT_LOG.parent, exist_ok=True)

class ReferenceRouter:
    def __init__(self):
        self.conn = sqlite3.connect(str(METADATA_DB))
        self._init_db()
    
    def _init_db(self):
        self.conn.execute("""CREATE TABLE IF NOT EXISTS metadata (
            id TEXT PRIMARY KEY, version TEXT, timestamp TEXT,
            hash TEXT, author TEXT DEFAULT 'MICO',
            verified INTEGER DEFAULT 0, source TEXT DEFAULT 'SSOT',
            priority INTEGER DEFAULT 1)""")
        self.conn.commit()
