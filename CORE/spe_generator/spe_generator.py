#!/usr/bin/env python3
"""Execution Orchestrator — menghasilkan SPE, status, next, evidence, manifest."""
import sys, os, json
from pathlib import Path
from datetime import datetime

BASE_DIR = Path(__file__).parent
TEMPLATE_FILE = BASE_DIR / "SPE_TEMPLATE.md"
REGISTRY_FILE = BASE_DIR / "module_registry.json"
STATE_FILE = BASE_DIR / "state.json"
QUEUE_FILE = BASE_DIR / "queue.json"
EVIDENCE_ROOT = Path.home() / "JDEQ" / "RUNTIME" / "evidence"

TARGET_TESTS = {
    "sovereign_kernel": "- verify SSOT\n- permission lock\n- audit log\n- versioning\n- conflict simulation",
    "reference_router": "- register\n- validate\n- reject\n- SSOT reference",
    "event_bus": "- publish\n- subscribe\n- dispatch\n- lifecycle\n- priority\n- ownership",
    "virtual_daemon": "- lazy instantiation\n- execute\n- destroy\n- gc.collect()\n- lifecycle\n- boundary SSOT",
    "version_validator": "- id\n- version\n- timestamp\n- hash\n- author\n- verified\n- source\n- priority",
    "integration_test": "- full integration\n- all modules connected",
    "audit_logger": "- append-only\n- timestamp\n- actor\n- module\n- decision\n- result",
    "command_center": "- read status\n- no logic\n- report generation"
}

def load_registry():
    return json.loads(REGISTRY_FILE.read_text())

def load_state():
    return json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else {}

def load_queue():
    return json.loads(QUEUE_FILE.read_text()) if QUEUE_FILE.exists() else []

def save_state(state):
    STATE_FILE.write_text(json.dumps(state, indent=2))

def save_queue(queue):
    QUEUE_FILE.write_text(json.dumps(queue, indent=2))

def generate_spe(module_name):
    registry = load_registry()
    if module_name not in registry:
        return f"❌ Modul '{module_name}' tidak dikenal. Pilihan: {', '.join(registry)}"
    
    template = TEMPLATE_FILE.read_text()
    tests = TARGET_TESTS.get(module_name, "- (tidak ada kontrak)")
    date_str = datetime.now().strftime("%Y%m%d")
    module_id = module_name.replace("_", "-").upper()
    
    spe = template.replace("{MODULE_NAME}", module_name)
    spe = spe.replace("{MODULE_ID}", module_id)
    spe = spe.replace("{DATE}", date_str)
    spe = spe.replace("{TARGET_TESTS}", tests)
    
    # Buat direktori evidence
    evidence_dir = EVIDENCE_ROOT / module_name
    evidence_dir.mkdir(parents=True, exist_ok=True)
    
    return spe

def get_next():
    state = load_state()
    registry = load_registry()
    for mod in registry:
        if state.get(mod) != "TERBUKTI":
            return mod
    return None

def get_status():
    state = load_state()
    registry = load_registry()
    total = len(registry)
    selesai = sum(1 for mod in registry if state.get(mod) == "TERBUKTI")
    tersisa = total - selesai
    return {
        "total": total,
        "selesai": selesai,
        "tersisa": tersisa,
        "persentase": f"{round((selesai/total)*100, 1)}%",
        "status_per_modul": state
    }

def create_manifest(module_name, evidence_files):
    evidence_dir = EVIDENCE_ROOT / module_name
    evidence_dir.mkdir(parents=True, exist_ok=True)
    manifest = {
        "modul": module_name,
        "timestamp": datetime.now().isoformat(),
        "file_bukti": evidence_files,
        "status": "TERBUKTI"
    }
    manifest_file = evidence_dir / "manifest.json"
    manifest_file.write_text(json.dumps(manifest, indent=2))
    return str(manifest_file)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Pemakaian:")
        print("  spe <module_name>   → Generate SPE")
        print("  spe next            → Tampilkan modul berikutnya")
        print("  spe status          → Tampilkan progres")
        sys.exit(1)
    
    cmd = sys.argv[1]
    
    if cmd == "next":
        next_mod = get_next()
        if next_mod:
            print(f"📋 Modul berikutnya: {next_mod}")
            print(generate_spe(next_mod))
        else:
            print("✅ Semua modul sudah TERBUKTI.")
    elif cmd == "status":
        status = get_status()
        print(json.dumps(status, indent=2))
    else:
        print(generate_spe(cmd))
