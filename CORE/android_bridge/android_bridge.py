#!/usr/bin/env python3
"""Android Bridge — menghubungkan Application Launcher dengan Intent Manager."""
import sys, json
from pathlib import Path

sys.path.insert(0, str(Path.home() / "JDEQ/CORE/application_launcher"))
sys.path.insert(0, str(Path.home() / "JDEQ/CORE/intent_manager"))

from application_launcher import ApplicationLauncher
from intent_manager import IntentManager

class AndroidBridge:
    def __init__(self):
        self.launcher = ApplicationLauncher()
        self.intent_manager = IntentManager()

    def prepare(self, app_name):
        """Siapkan aplikasi untuk diluncurkan. Mengembalikan Intent + Status."""
        launch_status = self.launcher.launch_by_name(app_name)
        if launch_status["status"] != "SIAP_DILUNCURKAN":
            return launch_status
        package = launch_status["package"]
        intent = self.intent_manager.get_intent(package)
        return {
            "status": "SIAP",
            "app": app_name,
            "package": package,
            "intent": intent
        }

    def list_ready(self):
        return [app["nama_aplikasi"] for app in self.launcher.list_ready()]

if __name__ == "__main__":
    bridge = AndroidBridge()
    print("=== SIAP DILUNCURKAN ===")
    for app in bridge.list_ready():
        result = bridge.prepare(app)
        print(f"  {app}: {result['status']}")
