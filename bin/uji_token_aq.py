import requests, os, sys

# Baca token AQ dari file
aq_file = os.path.expanduser("~/JDEQ/VAULT/KEYS/rotasi/kunci_aq_sementara.txt")
if not os.path.exists(aq_file):
    print("❌ File token AQ tidak ditemukan")
    sys.exit(1)

with open(aq_file) as f:
    tokens = [l.strip() for l in f if l.strip() and l.startswith("AQ.")]

aktif = []
for token in tokens:
    # Uji sebagai Bearer token (OAuth) ke Gemini API
    headers = {"Authorization": f"Bearer {token}"}
    try:
        r = requests.post(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
            headers=headers,
            json={"contents":[{"parts":[{"text":"ping"}]}]},
            timeout=5
        )
        if r.status_code == 200:
            aktif.append(token)
            print(f"✅ Token AQ {token[:20]}... AKTIF")
        else:
            print(f"❌ Token AQ {token[:20]}... {r.status_code}")
    except Exception as e:
        print(f"⚠️ Token AQ {token[:20]}... error: {str(e)[:50]}")

# Simpan token yang aktif ke file khusus
if aktif:
    with open(os.path.expanduser("~/JDEQ/VAULT/KEYS/active/token_aq_aktif.txt"), "w") as f:
        f.write(aktif[0])  # Simpan yang pertama
    print(f"✅ {len(aktif)} token AQ aktif. Disimpan untuk cloud agent.")
else:
    print("❌ Tidak ada token AQ yang aktif. Semua mungkin sudah kadaluwarsa.")
