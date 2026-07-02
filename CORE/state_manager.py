#!/data/data/com.termux/files/usr/bin/python3
import os,json,time
F=os.path.join(os.path.dirname(__file__),"runtime_state.json")
def s(k,v):
 d=load();d[k]={"value":v,"timestamp":time.time()}
 with open(F,"w") as f:json.dump(d,f,indent=2)
def load():
 if os.path.exists(F):
  with open(F) as f:return json.load(f)
 return{}
def g(k,default=None):return load().get(k,{}).get("value",default)
