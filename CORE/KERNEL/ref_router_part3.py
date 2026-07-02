    def _audit(self, doc_id, status, reason=""):
        entry = {"time": str(datetime.now()), "actor": "ReferenceRouter",
                 "document": doc_id, "decision": status, "result": reason}
        with open(AUDIT_LOG, "a") as f:
            f.write(json.dumps(entry) + "\n")

if __name__ == "__main__":
    router = ReferenceRouter()
    content = "MICO-JDEQ Blueprint V7"
    reg = router.register_metadata("BLUEPRINT_V7", "7.0.0", content)
    print(f"✅ Register: {reg['hash']}")
    val = router.validate_document("BLUEPRINT_V7", content)
    print(f"✅ Validasi: {val['status']}")
