#!/usr/bin/env python3
"""MICO Virtual Daemon Architecture Core — Blueprint V6"""
import json, time, os, gc
from datetime import datetime
from pathlib import Path
from collections import deque

STATE_DIR = Path.home() / "JDEQ/CORE/STATE"
os.makedirs(STATE_DIR, exist_ok=True)

class vDaemon:
    STATES = ["INIT", "WAIT", "RUN", "SLEEP", "STOP"]
    def __init__(self, name):
        self.name = name; self.state = "INIT"; self.memory = {}; self.last_run = None
    def wake(self, event):
        if self.state == "SLEEP": self.state = "WAIT"
        if event: self.state = "RUN"; self.last_run = str(datetime.now())
    def sleep(self): self.state = "SLEEP"; self.memory.clear()
    def status(self): return {"name": self.name, "state": self.state}

class SovereignKernel:
    def __init__(self):
        # Lazy vDaemon — tidak dibuat semua di awal
        self._vDaemon_cache = {}
        # Priority Event Queue — pakai deque untuk FIFO + prioritas
        self.event_queue = deque(maxlen=500)
        self.state_file = STATE_DIR / "kernel_state.json"
        # Adaptive sleep interval
        self.sleep_interval = 5
    
    def get_vDaemon(self, name):
        if name not in self._vDaemon_cache:
            self._vDaemon_cache[name] = vDaemon(name)
        return self._vDaemon_cache[name]
    
    def dispatch(self, event_type, payload=None):
        if payload is None: payload = {}
        event = {"type": event_type, "payload": payload, "timestamp": str(datetime.now())}
        self.event_queue.append(event)
        
        routing = {
            "INPUT": ["vContext"], "BATTERY_LOW": ["vPolicy", "vRecovery"],
            "RAM_LOW": ["vPolicy", "vRecovery"], "INTENT_FOUND": ["vIntent", "vCapability", "vPlanner"],
            "SERVICE_DOWN": ["vRecovery", "vAudit"], "NETWORK_UP": ["vContext"],
            "NETWORK_DOWN": ["vRecovery"],
            # DEFAULT_HANDLER — event SYSTEM_BOOT atau unknown dicatat
            "_DEFAULT": ["vAudit"]
        }
        
        targets = routing.get(event_type, routing["_DEFAULT"])
        for name in targets:
            vd = self.get_vDaemon(name)
            vd.wake(event)
        
        # Consume event — bersihkan dari queue setelah diproses
        self._consume()
        
        # Garbage collector — paksa bersihkan memori Python
        self._gc()
        
        return {"dispatched": len(targets), "targets": targets}
    
    def _consume(self):
        """Bersihkan event yang sudah diproses"""
        while len(self.event_queue) > 0:
            self.event_queue.popleft()
    
    def _gc(self):
        """Garbage collector agresif"""
        gc.collect()
    
    def adaptive_sleep(self):
        """Tidur dinamis berdasarkan beban"""
        if len(self.event_queue) > 10:
            self.sleep_interval = 1
        elif len(self.event_queue) > 5:
            self.sleep_interval = 3
        else:
            self.sleep_interval = 5
        time.sleep(self.sleep_interval)

if __name__ == "__main__":
    kernel = SovereignKernel()
    print("╔══════════════════════════════════════╗")
    print("║   MICO VDA V6 — Coroutine Scheduler ║")
    print("║   Lazy Creation + Adaptive Sleep    ║")
    print("╚══════════════════════════════════════╝")
    
    events = ["SYSTEM_BOOT", "BATTERY_LOW", "INTENT_FOUND", "RAM_LOW"]
    for evt in events:
        result = kernel.dispatch(evt)
        print(f"   📡 {evt} → {result['dispatched']} vDaemon")
    
    print(f"\n   🧹 Event Queue: {len(kernel.event_queue)} (harus 0)")
    print(f"   🌙 Adaptive Sleep: {kernel.sleep_interval}s")
    print(f"   ✅ vDaemon dibuat: {len(kernel._vDaemon_cache)} (hanya yang dipakai)")
