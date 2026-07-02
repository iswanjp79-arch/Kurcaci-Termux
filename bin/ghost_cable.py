#!/data/data/com.termux/files/usr/bin/python3
# GHOST CABLE - Hubungkan semua perangkat & sync

import subprocess
import os
import time
import sys

HOME = os.path.expanduser("~")
LOG_DIR = os.path.join(HOME, "JDEQ/logs")
os.makedirs(LOG_DIR, exist_ok=True)

def log(msg):
    with open(os.path.join(LOG_DIR, "ghost_cable.log"), "a") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}\n")
    print(msg)

def run_script(script, args=None):
    cmd = ["bash", script]
    if args:
        cmd.extend(args)
    try:
        subprocess.run(cmd, check=True)
        log(f"✅ {script} selesai")
        return True
    except subprocess.CalledProcessError as e:
        log(f"❌ {script} gagal: {e}")
        return False

def main():
    log("⚡ Kabel Ghoib Terpasang. Sari-sari Inti siap dimasak.")

    # 1. Buka tunnel SSH ke Singapura (background)
    log("🔧 Membuka tunnel...")
    tunnel_script = os.path.join(HOME, "JDEQ/bin/tunnel_ssh.sh")
    # Jalankan tunnel di background (tanpa blocking)
    subprocess.Popen(["bash", tunnel_script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(5)  # tunggu tunnel terbentuk

    # 2. Sync dari Google Drive ke lokal
    log("📥 Sync Google Drive → lokal")
    run_script(os.path.join(HOME, "JDEQ/bin/sync_jdeq_ringan.sh"))

    # 3. Backup dari lokal ke Google Drive
    log("📤 Backup lokal → Google Drive")
    run_script(os.path.join(HOME, "JDEQ/bin/backup_rclone_ringan.sh"))

    # 4. Tutup tunnel (opsional, bisa di-keep)
    # subprocess.run(["pkill", "-f", "ssh -f -N -L"])
    log("✅ Semua selesai. Sari-sari inti siap.")

if __name__ == "__main__":
    main()
