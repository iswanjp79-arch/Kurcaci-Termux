import http.server, json, sys
from pathlib import Path

VAULT = Path.home() / "JDEQ" / "vault" / "api_keys.json"

class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers['Content-Length'])
        data = json.loads(self.rfile.read(length))
        vault = json.loads(VAULT.read_text())
        vault['tiktok'] = data
        VAULT.write_text(json.dumps(vault, indent=2))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK")
        print("[OK] Token TikTok disimpan")
        sys.exit(0)

server = http.server.HTTPServer(('127.0.0.1', 5555), Handler)
print("Menunggu token di 127.0.0.1:5555...")
server.handle_request()
