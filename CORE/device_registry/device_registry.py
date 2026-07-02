#!/usr/bin/env python3
"""Device Registry — membandingkan Application Registry dengan paket Android terpasang."""
import subprocess, json, sys
from pathlib import Path

sys.path.insert(0, str(Path.home() / "JDEQ/CORE/application_registry"))
from application_registry import ApplicationRegistry

class DeviceRegistry:
    def __init__(self):
        self.reg = ApplicationRegistry()
        self.installed = self._list_installed()

    def _list_installed(self):
        result = subprocess.run(["pm", "list", "packages"], capture_output=True, text=True)
        packages = []
        for line in result.stdout.splitlines():
            if line.startswith("package:"):
                packages.append(line.replace("package:", "").strip())
        return packages

    def compare(self):
        report = {}
        for pkg, app in self.reg.registry.items():
            if pkg in self.installed:
                report[pkg] = {"status": "FOUND", "app": app["nama_aplikasi"]}
            else:
                report[pkg] = {"status": "MISSING", "app": app["nama_aplikasi"]}
        return report

    def summary(self):
        comp = self.compare()
        found = sum(1 for c in comp.values() if c["status"] == "FOUND")
        missing = sum(1 for c in comp.values() if c["status"] == "MISSING")
        return {"total": len(comp), "found": found, "missing": missing}

if __name__ == "__main__":
    dr = DeviceRegistry()
    print(json.dumps(dr.compare(), indent=2))
    print("\nSummary:", dr.summary())
