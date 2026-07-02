#!/usr/bin/env python3
import json
STORES = {"ssd": "~/JDEQ", "cloud": "gdrive:Backup_Platform_AI", "infinix": "100.103.39.81:/JDEQ_CLONE"}
def resolve(knowledge_id):
    return STORES.get("ssd", "unknown")
if __name__ == "__main__":
    print(f"Storage for 'drawing-001': {resolve('drawing-001')}")
    print("✅ Storage Manager aktif")
