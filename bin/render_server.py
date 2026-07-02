#!/usr/bin/env python3
"""MICO Render Server - Dashboard real-time di browser Android"""
import http.server, json, os, subprocess, sys
from datetime import datetime

PORT = 8083

class RenderHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            html = """<!DOCTYPE html>
<html><head><title>MICO Dashboard</title><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body{font-family:monospace;background:#1a1a2e;color:#e0e0e0;padding:10px}
h1{color:#00ff88}.card{background:#16213e;padding:10px;margin:5px 0;border-radius:8px}
.green{color:#00ff88}.red{color:#ff5555}.yellow{color:#ffaa00}
</style></head><body>
<h1>🖥️ MICO Dashboard</h1>
<div id="data">Memuat...</div>
<script>
async function load(){try{let r=await fetch('/api');let d=await r.json();document.getElementById('data').innerHTML=d.html;}catch(e){document.getElementById('data').innerHTML='Gagal memuat';}}
load();setInterval(load,5000);
</script></body></html>"""
            self.wfile.write(html.encode())
        elif self.path == "/api":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            # Data real-time
            ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
            llm = "✅" if os.popen("pgrep llama-server").read().strip() else "❌"
            ghost = "✅" if os.popen("pgrep -f ghost_relay.py").read().strip() else "❌"
            infinix = "✅" if os.popen("ping -c 1 -W 1 100.103.39.81").read().find("1 received") > -1 else "❌"
            html = f"""
<div class="card">RAM: {ram} MB free</div>
<div class="card">LLM: <span class="{'green' if llm=='✅' else 'red'}">{llm}</span></div>
<div class="card">Ghost: <span class="{'green' if ghost=='✅' else 'red'}">{ghost}</span></div>
<div class="card">Infinix: <span class="{'green' if infinix=='✅' else 'red'}">{infinix}</span></div>
<div class="card">Waktu: {datetime.now().strftime('%H:%M:%S')}</div>
"""
            self.wfile.write(json.dumps({"html": html}).encode())
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    print(f"Render server di http://localhost:{PORT}")
    http.server.HTTPServer(("0.0.0.0", PORT), RenderHandler).serve_forever()
