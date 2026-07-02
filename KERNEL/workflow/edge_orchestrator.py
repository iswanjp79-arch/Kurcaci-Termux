"""Edge Orchestrator — Workflow untuk MICO Kernel"""
import json, time, sqlite3, os
from pathlib import Path
from datetime import datetime

B = Path.home() / "JDEQ"
MEMORY_DB = B / "KERNEL" / "memory" / "mico_memory.db"

def log_decision(agent, input_summary, decision):
    conn = sqlite3.connect(str(MEMORY_DB))
    conn.execute(
        "INSERT INTO decisions (timestamp, agent, input, decision) VALUES (?, ?, ?, ?)",
        (datetime.now().isoformat(), agent, input_summary[:200], json.dumps(decision))
    )
    conn.commit()
    conn.close()

def check_quota():
    with open(B / "KERNEL" / "policy" / "quota_policy.json") as f:
        policy = json.load(f)
    return policy["current_usage_mb"] < policy["monthly_limit_mb"]

def execute_local(task):
    """Eksekusi tugas lokal tanpa cloud."""
    return {"status": "done", "by": "mico_kernel", "result": f"Local: {task[:50]}..."}

def execute_cloud(agent, task):
    """Panggil agen cloud (simulasi - akan diganti API call)."""
    # Di sini nanti dipanggil call_ai() dari ai_router
    return {"status": "dispatched", "to": agent, "task": task[:100]}

if __name__ == "__main__":
    print("Edge Orchestrator siap.")
    log_decision("mico", "init", {"status": "kernel_ready"})
