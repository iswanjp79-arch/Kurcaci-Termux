"""MICO v3.0 – Entitas Digital Terintegrasi (Lapis 6)"""
import os, json, subprocess, sys
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
IDENTITY_PATH = os.path.join(JDEQ, "CORE_PROTOCOL/mico_identity.json")
AUDIT_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")
DECISION_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.log")

def audit(msg):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(AUDIT_LOG, "a") as f:
        f.write(f"[{ts}] MICO [{msg}]\n")
    print(f"[MICO] {msg}")

# ========== AWARENESS ==========
def cek_kesadaran():
    """MICO mriksa awake dhewe."""
    print("="*50)
    print("  MICO RUNTIME AWARENESS")
    print("="*50)
    
    # Identitas
    if os.path.isfile(IDENTITY_PATH):
        with open(IDENTITY_PATH) as f:
            ident = json.load(f)
        print(f"IDENTITAS : {ident['nama']} v{ident['versi']} – {ident['peran']}")
        print(f"PEMILIK   : {ident['pemilik']}")
        audit(f"Identitas: {ident['nama']} v{ident['versi']}")
    else:
        print("IDENTITAS : GAGAL")
        return False
    
    # Lingkungan
    from environment_engine import get_env_info, check_storage
    env = get_env_info()
    storage = check_storage()
    print(f"OS        : {env['os']} | Python {env['python'].split()[0]}")
    print(f"SQLite    : {env['sqlite']}")
    print(f"Termux    : {'YA' if env['termux'] else 'TIDAK'}")
    print(f"Debian    : {'YA' if env['debian_proot'] else 'TIDAK'}")
    print(f"Storage   : {storage['used_percent']}% terpakai ({storage['free_gb']:.1f} GB bebas)")
    audit(f"Env: {env['os']}, Storage: {storage['used_percent']}%")
    
    # Governance
    from governance_engine import check_compliance
    compliance = check_compliance()
    print(f"SSOT      : {'PASS' if compliance['ssot_exists'] else 'FAIL'}")
    print(f"Audit Log : {'PASS' if compliance['audit_log_exists'] else 'FAIL'}")
    print(f"Backup    : {'PASS' if compliance['backup_exists'] else 'FAIL'}")
    
    # Agent Registry
    from lapis_bridge import load_agent_registry
    agents = load_agent_registry()
    if agents:
        aktif = [a['id'] for a in agents['agents'] if a['status'] == 'aktif']
        print(f"Agen Aktif: {', '.join(aktif)}")
    
    print("="*50)
    print("[MICO] AWARENESS COMPLETE – SIAP KERJA")
    return True

if __name__ == "__main__":
    if cek_kesadaran():
        audit("MICO READY")
    else:
        audit("MICO GAGAL – Identitas tidak ditemukan")
        sys.exit(1)
