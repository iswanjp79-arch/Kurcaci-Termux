import json
import os
import sys
from datetime import datetime

# Path standar JDEQ
DATA_IN_PATH = os.path.expanduser("~/JDEQ/DATA_IN/incoming/field_data.json")
AUDIT_LOG_PATH = os.path.expanduser("~/JDEQ/CORE_MEMORY/logs/audit.log")

def tulis_audit(pemicu, tindakan, hasil, status):
    """Nyathet jejak digital ing audit log."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{pemicu}] [{tindakan}] [{hasil}] [{status}]\n"
    os.makedirs(os.path.dirname(AUDIT_LOG_PATH), exist_ok=True)
    with open(AUDIT_LOG_PATH, "a") as f:
        f.write(log_entry)
    print(f"[AUDIT] {log_entry.strip()}")

def validasi_data(path_file):
    """
    Fungsi utama kangge validasi data lapangan.
    Input: Path menyang file JSON
    Output: True yen data valid, False yen ora
    """
    pemicu = "VALIDASI_DATA"
    
    # 1. Priksa ketersediaan file
    print("[VALIDATOR] 1. Priksa file...")
    if not os.path.isfile(path_file):
        tulis_audit(pemicu, "Priksa file", "Gagal", "HOLD")
        print("[VALIDATOR] HOLD: File data lapangan ora ditemukan.")
        return False
    print("[VALIDATOR] File ditemukan.")

    # 2. Priksa format JSON
    print("[VALIDATOR] 2. Priksa format JSON...")
    try:
        with open(path_file, 'r') as f:
            data = json.load(f)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        tulis_audit(pemicu, "Priksa JSON", f"Gagal: {e}", "HOLD")
        print(f"[VALIDATOR] HOLD: Format JSON ora valid. Error: {e}")
        return False
    print("[VALIDATOR] Format JSON valid.")

    # 3. Priksa data kosong utawa kunci wajib ilang
    print("[VALIDATOR] 3. Priksa isi data...")
    kunci_wajib = ["timestamp", "data_points", "status"]
    for kunci in kunci_wajib:
        if kunci not in data or data[kunci] is None:
            tulis_audit(pemicu, "Priksa Isi", f"Gagal: Kunci '{kunci}' ilang/kosong", "HOLD")
            print(f"[VALIDATOR] HOLD: Data '{kunci}' wajib diisi.")
            return False
    print("[VALIDATOR] Data katon lengkap.")

    # 4. Kabeh priksa lolos
    tulis_audit(pemicu, "Validasi Lengkap", "Lulus", "PASS")
    print("[VALIDATOR] PASS: Data valid.")
    return True

# --- CONTOH PANGGILAN ---
if __name__ == "__main__":
    print("[VALIDATOR] Miwiti proses validasi...")
    # Kanggo testing, kita bakal nggunakake path standar
    hasil = validasi_data(DATA_IN_PATH)
    if hasil:
        print("[VALIDATOR] Status Akhir: PASS")
        sys.exit(0)
    else:
        print("[VALIDATOR] Status Akhir: HOLD")
        sys.exit(1)
