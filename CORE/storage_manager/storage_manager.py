#!/usr/bin/env python3
import json, os
class StorageManager:
    def __init__(self, p="~/JDEQ/CORE/STATE"): self.p=os.path.expanduser(p); os.makedirs(self.p,exist_ok=True)
    def save(self, k, d):
        with open(os.path.join(self.p,f"{k}.json"),"w") as f: json.dump(d,f)
    def load(self, k):
        try:
            with open(os.path.join(self.p,f"{k}.json")) as f: return json.load(f)
        except: return None
