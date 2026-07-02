import os
import requests

def call_cloud(prompt):
    url_file = os.path.expanduser("~/JDEQ/bridge/ngrok_url.txt")
    if not os.path.exists(url_file):
        return "❌ Alamat server belum disimpan"
    
    with open(url_file, "r") as f:
        url = f.read().strip()
    
    try:
        response = requests.post(
            url,
            json={"messages": [{"role": "user", "content": prompt}]},
            timeout=15
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        return f"⚠️ Kesalahan koneksi: {str(e)}"
