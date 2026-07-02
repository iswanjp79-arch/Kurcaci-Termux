#!/data/data/com.termux/files/usr/bin/python3
import os,time
R=os.path.join(os.path.dirname(__file__),"..","DATA_OUT","reports")
def generate_report(title,content):
 os.makedirs(R,exist_ok=True)
 f=os.path.join(R,f"report_{int(time.time())}.md")
 with open(f,"w") as fp:fp.write(f"# {title}\n\n{content}")
 print(f"Laporan: {f}")
 return f
