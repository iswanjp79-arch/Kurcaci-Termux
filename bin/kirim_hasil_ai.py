import socket, json, subprocess, sys, time
from datetime import datetime

INFINIX_IP = "100.103.39.81"
INFINIX_PORT = 9999
LOG_FILE = "/data/data/com.termux/files/home/JDEQ/logs/ai_sent.log"

def kirim(prompt):
    """Jalankan llama-cli dan kirim hasilnya ke Infinix"""
    
    # Jalankan llama-cli dengan prompt
    start = time.time()
    result = subprocess.run(
        ["llama-cli", "-m", "/data/data/com.termux/files/home/JDEQ/models/mico.gguf", "-p", prompt, "--simple-io", "--no-display-prompt"],
        capture_output=True,
        text=True,
        timeout=120
    )
    elapsed = round(time.time() - start, 2)
    
    hasil = {
        "waktu": datetime.now().isoformat(),
        "prompt": prompt,
        "jawaban": result.stdout.strip(),
        "durasi_detik": elapsed,
        "error": result.stderr.strip() if result.stderr else ""
    }
    
    # Kirim ke Infinix
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((INFINIX_IP, INFINIX_PORT))
            s.sendall(json.dumps(hasil, ensure_ascii=False).encode())
        print(f"[✅] Hasil terkirim ke Infinix dalam {elapsed} detik")
    except Exception as e:
        print(f"[❌] Gagal mengirim: {e}")
    
    # Simpan ke log lokal
    with open(LOG_FILE, "a") as f:
        f.write(json.dumps(hasil, ensure_ascii=False) + "\n")
    
    print(hasil["jawaban"])

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Pemakaian: python3 kirim_hasil_ai.py \"Pertanyaan Anda\"")
        sys.exit(1)
    prompt = " ".join(sys.argv[1:])
    kirim(prompt)
