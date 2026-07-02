#!/usr/bin/env python3
import json
from pathlib import Path

APP_ROOT = Path.home() / "JDEQ" / "APPLICATION"

class ApplicationRegistry:
    def __init__(self):
        self.registry = {}
        self.load()

    def load(self):
        self.registry = {}
        for folder in APP_ROOT.iterdir():
            if not folder.is_dir():
                continue
            app_file = folder / "app.json"
            if not app_file.exists():
                continue
            with open(app_file, "r") as f:
                data = json.load(f)
            self.registry[data["package_name"]] = data
        return self.registry

    def validate(self):
        required = [
            "nama_aplikasi", "package_name", "kategori", "tier",
            "fungsi", "permission", "dependency", "launch_method",
            "stop_method", "status"
        ]
        errors = []
        for pkg, data in self.registry.items():
            for item in required:
                if item not in data:
                    errors.append(f"{pkg} missing {item}")
        return errors

    def list_ready(self):
        return [x for x in self.registry.values() if x["status"] == "READY"]

    def list_not_ready(self):
        return [x for x in self.registry.values() if x["status"] != "READY"]

    def get(self, pkg):
        return self.registry.get(pkg)

    def summary(self):
        return {
            "total": len(self.registry),
            "ready": len(self.list_ready()),
            "not_ready": len(self.list_not_ready())
        }

if __name__ == "__main__":
    reg = ApplicationRegistry()
    print("=== SUMMARY ===")
    print(reg.summary())
    print()
    print("=== READY ===")
    for x in reg.list_ready():
        print(x["nama_aplikasi"])
    print()
    print("=== NOT READY ===")
    for x in reg.list_not_ready():
        print(x["nama_aplikasi"])
    print()
    err = reg.validate()
    if err:
        print("VALIDATION ERROR")
        for e in err:
            print(e)
    else:
        print("VALIDATION PASS")
