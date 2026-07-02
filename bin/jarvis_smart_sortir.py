import os, sys, time

VAULT_PATH = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/jarvis_vault.txt")

def muat_kunci():
    if os.path.exists(VAULT_PATH):
        with open(VAULT_PATH, "r") as f:
            return [line.strip() for line in f if line.strip() and "AIza" in line]
    return []

def dapatkan_kunci_aktif():
    """Coba kunci satu per satu, kembalikan yang pertama berhasil."""
    kunci_list = muat_kunci()
    if not kunci_list:
        return None
    
    for i, key in enumerate(kunci_list):
        try:
            import requests
            resp = requests.post(
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
                params={"key": key},
                json={"contents": [{"parts": [{"text": "ping"}]}]},
                timeout=10
            )
            if resp.status_code == 200:
                print(f"✅ Kunci #{i+1} aktif")
                return key
            elif resp.status_code == 429:
                print(f"⏳ Kunci #{i+1} kuota habis, mencoba berikutnya...")
            else:
                print(f"⚠️ Kunci #{i+1} error: {resp.status_code}")
        except:
            print(f"❌ Kunci #{i+1} gagal terhubung")
    
    print("🚨 Semua kunci telah habis kuota!")
    return None

if __name__ == "__main__":
    kunci = dapatkan_kunci_aktif()
    if kunci:
        print(f"🔑 Kunci terpilih: {kunci[:10]}...")
        # Simpan ke environment untuk digunakan modul lain
        with open(os.path.expanduser("~/JDEQ/VAULT/KEYS/active/gemini_primary.env"), "w") as f:
            f.write(f"GEMINI_API_KEY={kunci}\n")
    else:
        print("❌ Tidak ada kunci tersedia.")
        sys.exit(1)
