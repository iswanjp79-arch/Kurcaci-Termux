#!/data/data/com.termux/files/usr/bin/python3
import http.server,socketserver,json,os,subprocess

class R(socketserver.TCPServer):allow_reuse_address=True

class H(http.server.SimpleHTTPRequestHandler):
    def __init__(self,*a,**kw):
        super().__init__(*a,directory=os.path.join(os.path.dirname(__file__),"..","CORE"),**kw)
    def do_GET(self):
        if self.path=='/status':
            s={"mico":self.p("llama-server","🟢 Aktif"),"jarvis":"🟢 Ready","chatgpt":"🟢 Ready","perplexity":"🟡 Placeholder","copilot":"🔴 Offline","dola":self.f("SSOT/MASTER_AUDIT_REPORT.md","🟢 Aktif"),"github":"🟡 Standby","emergent":self.f("CORE/orchestrator.py","🟢 Aktif")}
            self.send_response(200);self.send_header("Content-Type","application/json");self.end_headers();self.wfile.write(json.dumps(s).encode())
        else:super().do_GET()
    def p(self,n,m):
        try:subprocess.check_output(["pgrep","-f",n]);return f"{m}\nPID: Aktif"
        except:return f"🔴 {n} mati"
    def f(self,p,m):
        return f"{m}\nOK" if os.path.exists(os.path.expanduser(f"~/JDEQ/{p}")) else f"🔴 {p} missing"

if __name__=="__main__":
    for port in range(8083,8090):
        try:
            with R(("",port),H) as httpd:
                print(f"🌐 Dashboard: http://localhost:{port}")
                httpd.serve_forever()
        except OSError:continue
        else:break
