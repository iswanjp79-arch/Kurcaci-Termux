#!/usr/bin/env python3

import json
import subprocess
import time
import traceback
from pathlib import Path

ROOT = Path.home() / "JDEQ"
RUNTIME = ROOT / "RUNTIME"
LOGDIR = ROOT / "logs"

TRIGGER = RUNTIME / "macrodroid_trigger.json"
LOCK = RUNTIME / ".bridge.lock"
LOG = LOGDIR / "macrodroid_bridge.log"

LOGDIR.mkdir(parents=True, exist_ok=True)
RUNTIME.mkdir(parents=True, exist_ok=True)

def write_log(msg):
    with LOG.open("a") as f:
        f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")

if LOCK.exists():
    write_log("Bridge sudah berjalan.")
    raise SystemExit(0)

LOCK.touch()

write_log("Bridge aktif.")

try:
    while True:

        if TRIGGER.exists():

            try:
                data = json.loads(TRIGGER.read_text())

                TRIGGER.unlink(missing_ok=True)

                action = data.get("action")

                if not isinstance(action, list):
                    write_log("Action tidak valid.")
                else:

                    target = action[-1]

                    if Path(target).exists():

                        write_log(f"Eksekusi: {' '.join(action)}")

                        result = subprocess.run(
                            action,
                            timeout=300,
                            capture_output=True,
                            text=True
                        )

                        write_log(f"Exit={result.returncode}")
                        if result.stdout:
                            write_log(result.stdout.strip())

                        if result.stderr:
                            write_log(result.stderr.strip())

                    else:
                        write_log(f"Target tidak ditemukan: {target}")

            except Exception as e:
                write_log(str(e))
                write_log(traceback.format_exc())

        time.sleep(2)

except KeyboardInterrupt:
    write_log("Bridge dihentikan.")

finally:
    LOCK.unlink(missing_ok=True)
