#!/data/data/com.termux/files/usr/bin/python3
"""
REGENERASI KUNCI GEMINI OTOMATIS
Menggunakan daftar akun Google untuk membuat API key baru
"""
import json, os, time, subprocess, sys

DB_AKUN = os.path.expanduser("~/JDEQ/VAULT/database_akun.json")
FILE_KUNCI = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/kunci_gemini.txt")

def muat_daftar_akun():
    if not os.path.exists(DB_AKUN):
        print("❌ Database akun tidak ditemukan")
        return []
    with open(DB_AKUN) as f:
        data = json.load(f)
    return data.get("klaster_google", [])

def regenerasi_kunci():
    """Mencoba membuat kunci baru untuk setiap akun Google."""
    akun_list = muat_daftar_akun()
    kunci_baru = []
    
    print(f"🔄 Mencoba regenerasi kunci untuk {len(akun_list)} akun...")
    
    for i, akun in enumerate(akun_list):
        print(f"   [{i+1}/{len(akun_list)}] {akun}...", end=" ")
        
        # Simulasi: buka Google AI Studio dan buat kunci
        # Untuk sekarang, kita catat bahwa kunci perlu dibuat manual
        # Karena pembuatan kunci API memerlukan browser dan login
        
        # Tapi kita bisa menyiapkan template untuk diisi nanti
        print("⏳ (perlu dibuat manual di aistudio.google.com)")
    
    # Simpan template untuk diisi
    with open(FILE_KUNCI, "w") as f:
        f.write("# Tempel kunci AIzaSy... baru di bawah ini, satu per baris\n")
        f.write("# Dibuat oleh regenerasi_kunci.py\n")
        f.write("# Akun tersedia: " + ", ".join(akun_list[:3]) + "...\n")
    
    print(f"\n📋 Template kunci disimpan di {FILE_KUNCI}")
    print("   Buka https://aistudio.google.com untuk setiap akun,")
    print("   buat API key, lalu tempel di file tersebut.")
    print("   Setelah itu jalankan: python3 ~/JDEQ/bin/uji_pilih_kunci.py")

if __name__ == "__main__":
    regenerasi_kunci()
