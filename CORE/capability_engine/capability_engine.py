#!/usr/bin/env python3
"""Capability Engine — membaca registry & menghasilkan Capability Registry tunggal."""
import sys, json
from pathlib import Path

sys.path.insert(0, str(Path.home() / "JDEQ/CORE/application_registry"))
from application_registry import ApplicationRegistry

class CapabilityEngine:
    def __init__(self):
        self.registry = ApplicationRegistry()
        self.capabilities = self._build()

    def _build(self):
        caps = {}
        for package, app in self.registry.registry.items():
            status = app["status"]
            caps[package] = {
                "app": app["nama_aplikasi"],
                "capability": "READY" if status == "READY" else "NOT_READY",
                "tier": app["tier"],
                "dependency": app["dependency"],
                "permission": app["permission"]
            }
        return caps

    def summary(self):
        return {
            "total": len(self.capabilities),
            "ready": sum(1 for c in self.capabilities.values() if c["capability"] == "READY"),
            "not_ready": sum(1 for c in self.capabilities.values() if c["capability"] == "NOT_READY")
        }

    def export(self):
        return self.capabilities

if __name__ == "__main__":
    ce = CapabilityEngine()
    print(json.dumps(ce.export(), indent=2))
    print("\nSummary:", ce.summary())
