#!/usr/bin/env python3
import sqlite3
import os
import sys
import json
from datetime import datetime

DB_PATH = os.path.expanduser("~/JDEQ/JDEQ.db")

def log(agent, action, detail=""):
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute("INSERT INTO audit_logs (agent, action, detail) VALUES (?, ?, ?)",
                (agent, action, detail))
    conn.commit()
    conn.close()
    print(f"[AUDIT] {agent}: {action} - {detail}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: audit_logger.py <agent> <action> [detail]")
        sys.exit(1)
    agent = sys.argv[1]
    action = sys.argv[2]
    detail = " ".join(sys.argv[3:]) if len(sys.argv) > 3 else ""
    log(agent, action, detail)
