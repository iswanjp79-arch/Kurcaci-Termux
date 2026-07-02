#!/data/data/com.termux/files/usr/bin/python3
import os,subprocess,sys
R={"pep":os.path.join(os.path.dirname(__file__),"..","PROJECT_CONTROL","PEP","generate_pep.py"),"cpm":os.path.join(os.path.dirname(__file__),"..","PROJECT_CONTROL","orchestrator.py"),"health":os.path.join(os.path.dirname(__file__),"orchestration","health_scheduler.py")}
def route(cmd):
 if cmd in R:
  t=R[cmd]
  if os.path.exists(t):subprocess.run([sys.executable,t])
  else:print(f"Tidak ditemukan: {t}")
 else:print(f"Perintah: {list(R.keys())}")
