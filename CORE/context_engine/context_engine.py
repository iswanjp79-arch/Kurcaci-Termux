#!/usr/bin/env python3
import os
class ContextEngine:
    def build(self):
        ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
        return {"ram_mb":int(ram) if ram.isdigit() else 0}
