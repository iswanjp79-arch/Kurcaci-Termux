import http.server, urllib.parse, requests, json, sys
from pathlib import Path

CLIENT_KEY = "awa2zp7z726vvo8f"
CLIENT_SECRET = "fUX8aI302S3Iis4sPmCh7LqDRGWkBOne"
VAULT = Path.home() / "JDEQ" / "vault" / "api_keys.json"

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        q = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(q)
        if 'code' in params:
            code = params['code'][0]
            resp = requests.post('https://open-api.tiktok.com/oauth/access_token/', data={
                'client_key': CLIENT_KEY,
                'client_secret': CLIENT_SECRET,
                'code': code,
                'grant_type': 'authorization_code',
                'redirect_uri': REDIRECT_URI
            })
            token_data = resp.json()
            vault = json.loads(VAULT.read_text())
            vault['tiktok'] = {
                'access_token': token_data.get('access_token'),
                'refresh_token': token_data.get('refresh_token'),
                'open_id': token_data.get('open_id')
            }
            VAULT.write_text(json.dumps(vault, indent=2))
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Token berhasil! Tutup tab.")
            print("[OK] Token TikTok tersimpan")
            sys.exit(0)
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Tidak ada kode.")

if __name__ == '__main__':
    REDIRECT_URI = f"{sys.argv[1]}/callback"
    server = http.server.HTTPServer(('', 5000), Handler)
    print(f"Server siap di {REDIRECT_URI}...")
    server.handle_request()
