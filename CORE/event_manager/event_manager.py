#!/usr/bin/env python3
class EventManager:
    def __init__(self): self.events=[]
    def publish(self, t, p=None): self.events.append({"type":t,"payload":p or {}}); return {"status":"PUBLISHED"}
