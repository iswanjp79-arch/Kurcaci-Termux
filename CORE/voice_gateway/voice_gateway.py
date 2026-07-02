#!/usr/bin/env python3
"""Voice Gateway — antarmuka Voice. Belum terhubung ke Gemini."""
import json

class VoiceGateway:
    def __init__(self):
        self.provider = "Gemini (belum terhubung)"
        self.status = "STANDBY"

    def status_report(self):
        return {
            "provider": self.provider,
            "status": self.status,
            "note": "Antarmuka Voice siap. Koneksi ke Gemini akan dilakukan pada SPE berikutnya."
        }

if __name__ == "__main__":
    vg = VoiceGateway()
    print(json.dumps(vg.status_report(), indent=2))
