#!/data/data/com.termux/files/usr/bin/python3
import os,json,time
L=os.path.join(os.path.dirname(__file__),"decisions.json")
def decide(event):
 d={"event":event,"action":"approved" if event.get("compliance",True) else "rejected","timestamp":time.time()}
 decisions=[]
 if os.path.exists(L):
  with open(L) as f:decisions=json.load(f)
 decisions.append(d)
 with open(L,"w") as f:json.dump(decisions[-100:],f,indent=2)
 return d
