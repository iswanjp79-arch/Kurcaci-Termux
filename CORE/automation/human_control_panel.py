import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"

def dashboard():
    """Panel kontrol manusia (Mas Iswan) - ringan, informatif."""
    print("=" * 55)
    print("  MICO HUMAN CONTROL PANEL – JDEQ V.20")
    print("=" * 55)
    
    # Status sistem
    print("[1] STATUS SISTEM")
    
    # Cek komponen utama
    checks = {
        "Supervisor": os.path.isfile(os.path.join(JDEQ, "supervisor_jdeq.sh")),
        "Orchestrator": os.path.isfile(os.path.join(JDEQ, "PROJECT_CONTROL/orchestrator.py")),
        "Reasoning": os.path.isfile(os.path.join(JDEQ, "CORE_REASONING/engineering_rule_engine.py")),
        "Validation": os.path.isfile(os.path.join(JDEQ, "CORE_VALIDATION/validation_engine.py")),
        "Security": os.path.isfile(os.path.join(JDEQ, "CORE_SECURITY/security_hardening.py")),
        "Recovery": os.path.isfile(os.path.join(JDEQ, "CORE_SECURITY/recovery_manager.py")),
    }
    for name, ok in checks.items():
        print(f"  {name:15} : {'✅ ONLINE' if ok else '❌ OFFLINE'}")
    
    # [2] Aksi Cepat
    print("\n[2] AKSI CEPAT (ketik perintah):")
    print("  1. generate_report   – Buat laporan PEP")
    print("  2. run_dashboard     – Tampilkan dashboard MICO")
    print("  3. health_check      – Cek kesehatan sistem")
    print("  4. exit              – Keluar panel")
    
    # [3] Input
    print("\n[3] PERINTAH ANDA: ", end="")
    return input().strip().lower()

def process_command(cmd):
    """Proses perintah dari panel kontrol."""
    valid = ["generate_report", "run_dashboard", "health_check"]
    
    if cmd in valid:
        print(f"\n[MICO] Menjalankan '{cmd}'...")
        # Panggil automation engine
        import subprocess
        script = os.path.join(JDEQ, "CORE_AUTOMATION/controlled_automation.py")
        subprocess.run(["python3", "-c", f"""
import sys
sys.path.insert(0, '{JDEQ}/CORE_AUTOMATION')
from controlled_automation import automation_engine
automation_engine('{cmd}', auto_execute=True)
"""])
    elif cmd == "exit":
        print("[MICO] Panel ditutup. MICO tetap berjalan.")
        return False
    else:
        print(f"[MICO] Perintah '{cmd}' tidak dikenal.")
    return True

if __name__ == "__main__":
    running = True
    while running:
        cmd = dashboard()
        if cmd:
            running = process_command(cmd)
