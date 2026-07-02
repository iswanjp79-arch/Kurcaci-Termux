import requests, os, glob

# Uji hanya kunci Gemini untuk penggunaan utama
gemini_file = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/kunci_gemini.txt")
with open(gemini_file) as f:
    kunci = [l.strip() for l in f if l.strip() and l.startswith("AIzaSy")]

sip = []
for k in kunci:
    try:
        r = requests.post(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key="+k,
            json={"contents":[{"parts":[{"text":"ping"}]}]}, timeout=5
        )
        if r.status_code == 200:
            sip.append(k)
    except: pass

# Simpan kembali hanya yang hidup
with open(gemini_file,"w") as f:
    f.write("\n".join(sip))

print(f"✅ Selesai: {len(sip)} kunci Gemini AKTIF disimpan.")
print("ℹ️ Kunci AQ. dan lainnya tersimpan di folder rotasi untuk kebutuhan lanjutan.")
