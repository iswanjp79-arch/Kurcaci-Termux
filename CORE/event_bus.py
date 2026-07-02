import uuid
import time
import json
import queue
import threading
from pathlib import Path

# Path absolut untuk file pendukung
JDEQ = Path.home() / "JDEQ"
DLQ_LOG = JDEQ / "LOGS" / "event_dlq.log"
AUDIT_LOG = JDEQ / "AUDIT" / "event_audit.jsonl"
EVENT_TYPES = JDEQ / "SSOT" / "EVENT_TYPES.json"

class EventBus:
    """
    Implementasi kanonik Event Bus MICO-JDEQ.
    Sesuai dengan SSOT/EVENT_BUS_SPEC.md.
    """
    def __init__(self):
        self.subscribers = {}
        self.priority = {"CRITICAL": 0, "HIGH": 1, "NORMAL": 2, "LOW": 3}
        self.queue = queue.PriorityQueue()
        self.ttl = {"CRITICAL": 999, "HIGH": 30, "NORMAL": 300, "LOW": 900}
        self._load_event_types()
        threading.Thread(target=self._dispatcher, daemon=True).start()

    def _load_event_types(self):
        try:
            with open(EVENT_TYPES) as f:
                self.valid_types = json.load(f)
        except Exception:
            self.valid_types = {}

    def publish(self, event_type, payload, priority="NORMAL"):
        if event_type not in self.valid_types:
            return {"status": "REJECTED", "reason": "UNKNOWN_EVENT_TYPE"}

        event = {
            "event_id": str(uuid.uuid4()),
            "schema_version": "1.0",
            "correlation_id": payload.get("correlation_id", ""),
            "event_type": event_type,
            "source_module": payload.get("source_module", "UNKNOWN"),
            "owner": self.valid_types[event_type]["owner"],
            "priority": priority,
            "timestamp": int(time.time()),
            "ttl": self.ttl.get(priority, 300),
            "payload": payload,
            "lifecycle": "CREATED"
        }
        self.queue.put((self.priority[priority], time.time(), event))
        return {"status": "CREATED", "event_id": event["event_id"]}

    def subscribe(self, event_type, handler, owner):
        sub_id = str(uuid.uuid4())
        self.subscribers.setdefault(event_type, {})
        self.subscribers[event_type][sub_id] = {"handler": handler, "owner": owner}
        return {"subscription_id": sub_id}

    def unsubscribe(self, sub_id):
        for event_type in self.subscribers:
            if sub_id in self.subscribers[event_type]:
                del self.subscribers[event_type][sub_id]
                return True
        return False

    def dispatch(self, event):
        """Mengirim event ke semua subscriber secara non-blocking."""
        event["lifecycle"] = "DISPATCHED"
        subs = self.subscribers.get(event["event_type"], {})
        for sub_id, sub in subs.items():
            t = threading.Thread(target=self._call_handler, args=(event, sub_id, sub), daemon=True)
            t.start()

    def _call_handler(self, event, sub_id, sub):
        """Memanggil handler dengan retry & DLQ."""
        try:
            sub["handler"](event)
        except Exception:
            self._retry_or_dlq(event, sub_id)

    def _retry_or_dlq(self, event, sub_id, attempt=0):
        if attempt < 2:
            time.sleep(1)
            try:
                self.subscribers[event["event_type"]][sub_id]["handler"](event)
            except Exception:
                self._retry_or_dlq(event, sub_id, attempt + 1)
        else:
            event["lifecycle"] = "DLQ"
            with open(DLQ_LOG, "a") as f:
                f.write(json.dumps(event) + "\n")

    def _dispatcher(self):
        while True:
            try:
                prio, ts, event = self.queue.get(timeout=1)
                if time.time() - ts > event["ttl"]:
                    event["lifecycle"] = "EXPIRED"
                    with open(DLQ_LOG, "a") as f:
                        f.write(json.dumps(event) + "\n")
                    continue

                self.dispatch(event)

                event["lifecycle"] = "PROCESSED"
                with open(AUDIT_LOG, "a") as f:
                    f.write(json.dumps(event) + "\n")
            except queue.Empty:
                continue
