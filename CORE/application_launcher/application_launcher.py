#!/usr/bin/env python3
import sys
from pathlib import Path

sys.path.insert(0, str(Path.home() / "JDEQ/CORE/application_registry"))
from application_registry import ApplicationRegistry

class ApplicationLauncher:
    def __init__(self):
        self.registry = ApplicationRegistry()

    def load_registry(self):
        return self.registry.load()

    def list_ready(self):
        return self.registry.list_ready()

    def list_not_ready(self):
        return self.registry.list_not_ready()

    def check_ready(self, package_name):
        app = self.registry.get(package_name)
        if not app:
            return "TIDAK_DITEMUKAN"
        return app["status"]

    def launch(self, package_name):
        app = self.registry.get(package_name)
        if not app:
            return {"status": "TIDAK_DITEMUKAN"}
        if app["status"] != "READY":
            return {
                "status": "BELUM_SIAP",
                "app": app["nama_aplikasi"]
            }
        return {
            "status": "SIAP_DILUNCURKAN",
            "app": app["nama_aplikasi"],
            "package": package_name
        }

    def launch_by_name(self, nama):
        for app in self.registry.registry.values():
            if app["nama_aplikasi"].lower() == nama.lower():
                return self.launch(app["package_name"])
        return {"status": "TIDAK_DITEMUKAN"}

if __name__ == "__main__":
    al = ApplicationLauncher()
    print("=== READY ===")
    for app in al.list_ready():
        print(app["nama_aplikasi"])
    print()
    print("=== TEST NOTION ===")
    print(al.launch_by_name("Notion"))
    print()
    print("=== TEST N8N ===")
    print(al.launch_by_name("n8n"))
