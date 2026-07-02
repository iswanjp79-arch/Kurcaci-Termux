#!/data/data/com.termux/files/usr/bin/python3
import json, os, subprocess, sys

VAULT_GPG = os.path.expanduser("~/JDEQ/VAULT/KEYS/encrypted/api_database.json.gpg")
ROTATION_STATE = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/rotation_state.json")
ENV_FILE = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/gemini_primary.env")

def get_password():
    """Ambil password dari environment variable."""
    return os.environ.get("VAULT_PASSWORD", None)

def decrypt_vault():
    """Dekripsi database ke memori."""
    password = get_password()
    if not password:
        print("❌ Set VAULT_PASSWORD dulu: export VAULT_PASSWORD='password_anda'")
        return None
    if not os.path.exists(VAULT_GPG):
        print("❌ Database terenkripsi tidak ditemukan")
        return None
    cmd = ["gpg", "--batch", "--yes", "--passphrase", password, "--decrypt", VAULT_GPG]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print("❌ Gagal dekripsi")
        return None
    return json.loads(result.stdout)

def load_rotation_state():
    """Muat status rotasi terakhir."""
    if os.path.exists(ROTATION_STATE):
        with open(ROTATION_STATE) as f:
            return json.load(f)
    return {}

def save_rotation_state(state):
    """Simpan status rotasi."""
    with open(ROTATION_STATE, 'w') as f:
        json.dump(state, f, indent=2)

def get_active_key(platform):
    """Ambil kunci aktif untuk platform tertentu dengan rotasi."""
    vault = decrypt_vault()
    if not vault:
        return None
    
    keys = vault.get(platform, [])
    if not keys:
        print(f"❌ Tidak ada kunci untuk {platform}")
        return None
    
    state = load_rotation_state()
    index = state.get(platform, 0)
    
    if index >= len(keys):
        index = 0
    
    # Simpan ke environment file
    key = keys[index]
    if platform == "gemini":
        with open(ENV_FILE, 'w') as f:
            f.write(f"GEMINI_API_KEY={key}\n")
    
    print(f"🔑 {platform.upper()} indeks {index}/{len(keys)-1}: {key[:10]}...")
    return key

def rotate_key(platform):
    """Rotasi ke kunci berikutnya (jika terkena limit)."""
    state = load_rotation_state()
    current = state.get(platform, 0)
    vault = decrypt_vault()
    if vault:
        total = len(vault.get(platform, []))
        next_index = (current + 1) % total if total > 0 else 0
        state[platform] = next_index
        save_rotation_state(state)
        print(f"🔄 {platform.upper()} dirotasi ke indeks {next_index}")
        # Update environment file
        get_active_key(platform)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Gunakan:")
        print("  python3 key_rotator.py get <platform>")
        print("  python3 key_rotator.py rotate <platform>")
        sys.exit(1)
    
    action = sys.argv[1]
    platform = sys.argv[2] if len(sys.argv) > 2 else "gemini"
    
    if action == "get":
        get_active_key(platform)
    elif action == "rotate":
        rotate_key(platform)
    else:
        print("Perintah tidak dikenal")
