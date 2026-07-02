import requests, os
f = os.path.expanduser("~/JDEQ/VAULT/KEYS/active/jarvis_vault.txt")
with open(f) as d: kunci = [l.strip() for l in d if l.strip() and l.startswith("AIzaSy")]
aktif = []
for k in kunci:
    try:
        r = requests.post(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key="+k,
            json={"contents":[{"parts":[{"text":"ping"}]}]}, timeout=5
        )
        if r.status_code == 200: aktif.append(k)
    except: pass
with open(f,"w") as x: x.write("\n".join(aktif))
print(f"✅ {len(aktif)} kunci aktif disimpan. Sisanya dibuang otomatis.")
