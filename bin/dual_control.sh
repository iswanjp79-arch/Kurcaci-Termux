#!/data/data/com.termux/files/usr/bin/bash
# Jika Infinix mati, Vivo ambil alih tugasnya
if ! ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1; then
  echo "[$(date)] Infinix OFFLINE — Vivo ambil alih" >> ~/JDEQ/logs/dual_control.log
  # Jalankan server lokal sebagai pengganti
  nohup python3 -c "from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(200); self.end_headers()
        self.wfile.write(b'{\"result\":\"Vivo takeover\"}')
HTTPServer(('0.0.0.0', 9000), H).serve_forever()" > /dev/null 2>&1 &
fi
