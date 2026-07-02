#!/usr/bin/env python3
"""MICO QWEN ASSISTANT — Asisten Rumah Tangga Digital"""
import subprocess, json, os
from pathlib import Path

JDEQ = Path.home() / "JDEQ"

def execute_command(cmd):
    """Jalankan perintah sistem"""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

# Daftar perintah yang bisa dijalankan
COMMANDS = {
    "backup": "cp -r ~/JDEQ/SSOT ~/JDEQ/backup/$(date +%Y%m%d-%H%M)",
    "cek_ram": "free -m | awk '/Mem/{print $4}'",
    "cek_storage": "df -h /data/data/com.termux/files/home | tail -1",
    "cek_infinix": "ping -c 1 -W 2 100.103.39.81 && echo 'ONLINE' || echo 'OFFLINE'",
    "bersihkan": "rm -rf ~/JDEQ/tmp/* && echo 'TMP dibersihkan'",
    "sinkronisasi": "cd ~/JDEQ/REPOSITORY && git pull",
    "status": "pgrep sshd && echo 'SSH: ON' || echo 'SSH: OFF'; pgrep mosquitto && echo 'MQTT: ON' || echo 'MQTT: OFF'",
}

print("🏠 MICO ASISTEN RUMAH TANGGA — Siap membantu.")
print("Perintah yang tersedia:")
for cmd in COMMANDS:
    print(f"  - {cmd}")

while True:
    try:
        perintah = input("\n📋 Apa yang harus dilakukan? (ketik 'help' untuk daftar): ").strip().lower()
        if perintah == "help":
            for cmd, desc in COMMANDS.items():
                print(f"  {cmd}: {desc}")
        elif perintah in COMMANDS:
            hasil = execute_command(COMMANDS[perintah])
            print(f"✅ Hasil: {hasil}")
        elif perintah == "keluar":
            print("👋 Sampai jumpa.")
            break
        else:
            print(f"❌ Perintah tidak dikenal: {perintah}")
    except KeyboardInterrupt:
        print("\n👋 Sampai jumpa.")
        break
