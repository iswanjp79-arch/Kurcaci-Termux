#!/data/data/com.termux/files/usr/bin/python3
import json, os, subprocess, sys

VAULT_RAW = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/api_database.json")
VAULT_GPG = os.path.expanduser("~/JDEQ/VAULT/KEYS/encrypted/api_database.json.gpg")

def create_empty_vault():
    """Buat database kosong dengan struktur standar."""
    return {
        "gemini": [],
        "deepseek": [],
        "groq": [],
        "openai": [],
        "huggingface": []
    }

def load_vault():
    """Muat database dari file mentah (jika ada)."""
    if os.path.exists(VAULT_RAW):
        with open(VAULT_RAW) as f:
            return json.load(f)
    return create_empty_vault()

def save_vault(data):
    """Simpan database mentah (sementara, untuk enkripsi)."""
    with open(VAULT_RAW, 'w') as f:
        json.dump(data, f, indent=2)

def encrypt_vault(password):
    """Enkripsi database dengan GPG."""
    cmd = ["gpg", "--batch", "--yes", "--passphrase", password, "-c", VAULT_RAW]
    subprocess.run(cmd, check=True)
    # Pindahkan file .gpg ke folder encrypted
    gpg_file = VAULT_RAW + ".gpg"
    if os.path.exists(gpg_file):
        os.rename(gpg_file, VAULT_GPG)
        os.remove(VAULT_RAW)
        print("✅ Database terenkripsi disimpan di:")
        print(f"   {VAULT_GPG}")
    else:
        print("❌ Enkripsi gagal")

def decrypt_vault(password):
    """Dekripsi database ke memori (tanpa menulis file)."""
    if not os.path.exists(VAULT_GPG):
        return create_empty_vault()
    cmd = ["gpg", "--batch", "--yes", "--passphrase", password, "--decrypt", VAULT_GPG]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print("❌ Password salah atau file rusak")
        sys.exit(1)
    return json.loads(result.stdout)

def add_key(platform, key):
    """Tambahkan kunci ke database."""
    vault = load_vault()
    if platform not in vault:
        vault[platform] = []
    if key not in vault[platform]:
        vault[platform].append(key)
        print(f"✅ Kunci ditambahkan ke {platform}")
    else:
        print(f"⚠️ Kunci sudah ada di {platform}")
    save_vault(vault)
    return vault

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Gunakan:")
        print("  python3 vault_encrypt.py add <platform> <key>")
        print("  python3 vault_encrypt.py encrypt <password>")
        print("  python3 vault_encrypt.py decrypt <password>")
        sys.exit(1)
    
    action = sys.argv[1]
    
    if action == "add" and len(sys.argv) >= 4:
        platform = sys.argv[2]
        key = sys.argv[3]
        add_key(platform, key)
        print("Jalankan: python3 vault_encrypt.py encrypt PASSWORD_ANDA")
    
    elif action == "encrypt" and len(sys.argv) >= 3:
        password = sys.argv[2]
        encrypt_vault(password)
    
    elif action == "decrypt" and len(sys.argv) >= 3:
        password = sys.argv[2]
        vault = decrypt_vault(password)
        print(json.dumps(vault, indent=2))
    
    else:
        print("Perintah tidak dikenal")
