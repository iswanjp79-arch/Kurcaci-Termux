"""Lapis 5 – Orchestrator: Manager sing ngendalikake PEP, Workflow, Agent"""
import os, subprocess, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
AUDIT_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")

def audit(msg):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(AUDIT_LOG, "a") as f:
        f.write(f"[{ts}] ORCHESTRATOR [{msg}]\n")
    print(f"[ORCHESTRATOR] {msg}")

def run_agent(agent_id):
    """Jalanaken agen miturut registry."""
    script_map = {
        "cpm": "PROJECT_CONTROL/orchestrator.py",
        "pep": "PROJECT_CONTROL/PEP/generate_pep.py"
    }
    if agent_id in script_map:
        script = os.path.join(JDEQ, script_map[agent_id])
        try:
            subprocess.run(["python3", script], check=True)
            audit(f"Agent {agent_id} EXECUTED")
            return True
        except subprocess.CalledProcessError:
            audit(f"Agent {agent_id} FAILED")
            return False
    audit(f"Agent {agent_id} NOT FOUND")
    return False

if __name__ == "__main__":
    audit("Orchestrator Manager START")
    # Muat PEP
    from lapis_bridge import load_pep
    pep = load_pep()
    if pep:
        audit(f"PEP dimuat: {pep['dna']['tujuan']}")
    # Muat Workflow
    from lapis_bridge import load_workflow
    wf = load_workflow()
    if wf:
        audit(f"Workflow dimuat: {wf['workflow']['arteri']}")
    audit("Orchestrator Manager END")
