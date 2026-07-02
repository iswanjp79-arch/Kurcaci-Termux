"""Lapis 0 – Tata Kelola (ISO 9001, ISO 31000, ISO 45001, OHSAS)"""
import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
GOV_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/governance.log")

RULES = {
    "iso_9001": "Manajemen mutu – dokumen, prosedur, bukti, monitoring, audit",
    "iso_31000": "Manajemen risiko – identifikasi, analisis, evaluasi, mitigasi",
    "iso_45001": "Keselamatan operasi – hazard, risk, control, incident log",
    "ssot": "Single Source of Truth – satu kebenaran, tidak ada versi ganda"
}

def log_gov(event, detail):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(GOV_LOG, "a") as f:
        f.write(f"[{ts}] GOVERNANCE [{event}] [{detail}]\n")

def check_compliance():
    """Priksa kepatuhan dasar JDEQ terhadap standar."""
    results = {}
    # SSOT check
    ssot_path = os.path.join(JDEQ, "SSOT")
    results["ssot_exists"] = os.path.isdir(ssot_path)
    # Audit log check
    audit_path = os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")
    results["audit_log_exists"] = os.path.isfile(audit_path)
    # Backup check
    backup_path = os.path.join(JDEQ, "backup")
    results["backup_exists"] = os.path.isdir(backup_path)
    # Tulis log
    log_gov("COMPLIANCE_CHECK", str(results))
    return results
