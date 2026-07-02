#!/usr/bin/env python3
"""Android Intent Manager — menghasilkan perintah Intent dari metadata app.json."""
import json, os
from pathlib import Path

APP_ROOT = Path.home() / "JDEQ" / "APPLICATION"

class IntentManager:
    def __init__(self):
        self.apps = {}
        self._load()

    def _load(self):
        for folder in APP_ROOT.iterdir():
            if not folder.is_dir():
                continue
            app_file = folder / "app.json"
            if not app_file.exists():
                continue
            with open(app_file) as f:
                data = json.load(f)
            self.apps[data["package_name"]] = data

    def get_intent(self, package_name):
        app = self.apps.get(package_name)
        if not app:
            return None
        return {
            "action": "android.intent.action.MAIN",
            "package": package_name,
            "launch_method": app.get("launch_method", "Android Intent"),
            "status": app.get("status", "UNKNOWN")
        }

    def list_all(self):
        return {pkg: self.get_intent(pkg) for pkg in self.apps}

if __name__ == "__main__":
    im = IntentManager()
    print(json.dumps(im.list_all(), indent=2))
