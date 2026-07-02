import uuid, time, json, threading, os, signal, subprocess
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
AUDIT_LOG = JDEQ / "AUDIT" / "daemon_audit.jsonl"
SPEC_FILE = JDEQ / "SSOT" / "VIRTUAL_DAEMON_SPEC.md"

class VirtualDaemon:
    def __init__(self):
        self.active = {}
        self.max_concurrent = 8
        self.timeout = 60
        self.resource_limit_mb = 100
        self.lock = threading.Lock()

    def _audit(self, event_type, execution_id, owner_module, status, detail=""):
        entry = {
            "timestamp": datetime.now().isoformat(),
            "event_type": event_type,
            "execution_id": execution_id,
            "owner_module": owner_module,
            "status": status,
            "detail": detail
        }
        with open(AUDIT_LOG, "a") as f:
            f.write(json.dumps(entry) + "\n")

    def instantiate(self, daemon_name, intent, payload, owner_module):
        with self.lock:
            if len(self.active) >= self.max_concurrent:
                return {"status": "REJECTED_MAX_CONCURRENT"}

            execution_id = str(uuid.uuid4())
            self.active[execution_id] = {
                "daemon_name": daemon_name,
                "intent": intent,
                "payload": payload,
                "owner_module": owner_module,
                "lifecycle": "CREATED",
                "pid": None,
                "started_at": time.time()
            }
            self._audit("DAEMON_CREATED", execution_id, owner_module, "CREATED")

        t = threading.Thread(target=self._run, args=(execution_id,), daemon=True)
        t.start()
        return {"status": "CREATED", "execution_id": execution_id}

    def _run(self, execution_id):
        with self.lock:
            daemon = self.active.get(execution_id)
            if not daemon:
                return
            daemon["lifecycle"] = "RUNNING"
            self._audit("DAEMON_STARTED", execution_id, daemon["owner_module"], "RUNNING")

        # Simulasi eksekusi dengan timeout nyata
        start = time.time()
        success = False
        try:
            while time.time() - start < self.timeout:
                # Cek resource limit
                mem_used = self._get_memory_usage()
                if mem_used > self.resource_limit_mb:
                    raise MemoryError(f"RAM limit exceeded: {mem_used}MB")
                time.sleep(0.1)
                # Simulasi: selesai setelah 2 detik
                if time.time() - start > 2:
                    success = True
                    break
        except MemoryError as e:
            success = False
            daemon["lifecycle"] = "FAILED"
            self._audit("DAEMON_FAILED", execution_id, daemon["owner_module"], "FAILED", str(e))
        except Exception as e:
            success = False
            daemon["lifecycle"] = "FAILED"
            self._audit("DAEMON_FAILED", execution_id, daemon["owner_module"], "FAILED", str(e))

        with self.lock:
            if not success and daemon["lifecycle"] != "FAILED":
                daemon["lifecycle"] = "FAILED_TIMEOUT"
                self._audit("DAEMON_FAILED_TIMEOUT", execution_id, daemon["owner_module"], "FAILED_TIMEOUT")
            elif success:
                daemon["lifecycle"] = "COMPLETED"
                self._audit("DAEMON_COMPLETED", execution_id, daemon["owner_module"], "COMPLETED")
            self._destroy(execution_id)

    def _get_memory_usage(self):
        """Dummy memory usage. Bisa diganti dengan membaca /proc/[pid]/stat."""
        return 0  # Placeholder

    def _destroy(self, execution_id):
        daemon = self.active.pop(execution_id, None)
        if daemon:
            daemon["lifecycle"] = "DESTROYED"
            self._audit("DAEMON_DESTROYED", execution_id, daemon["owner_module"], "DESTROYED")
        import gc
        gc.collect()

    def destroy(self, execution_id):
        with self.lock:
            if execution_id in self.active:
                self._destroy(execution_id)
                return True
        return False

    def list_active(self):
        with self.lock:
            return list(self.active.keys())
