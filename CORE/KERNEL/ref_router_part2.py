    def validate_document(self, doc_id, content):
        result = {"status": "PENDING", "document_id": doc_id}
        row = self.conn.execute("SELECT * FROM metadata WHERE id = ?", (doc_id,)).fetchone()
        if not row:
            result["status"] = "REJECTED"
            self._audit(doc_id, "REJECTED", "METADATA_NOT_FOUND")
            return result
        stored_hash = row[3]
        if hashlib.sha256(content.encode()).hexdigest() != stored_hash:
            result["status"] = "REJECTED"
            self._audit(doc_id, "REJECTED", "HASH_MISMATCH")
            return result
        result["status"] = "APPROVED"
        self._audit(doc_id, "APPROVED", f"Version: {row[1]}")
        return result
    
    def register_metadata(self, doc_id, version, content, source="SSOT", priority=1):
        doc_hash = hashlib.sha256(content.encode()).hexdigest()
        self.conn.execute("INSERT OR REPLACE INTO metadata VALUES (?,?,?,?,?,?,?,?)",
            (doc_id, version, str(datetime.now()), doc_hash, "MICO", 1, source, priority))
        self.conn.commit()
        return {"status": "REGISTERED", "id": doc_id, "version": version, "hash": doc_hash[:16]}
