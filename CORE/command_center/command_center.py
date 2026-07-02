#!/usr/bin/env python3
"""MICO-JDEQ COMMAND CENTER — Dashboard Pemantauan Real-Time"""
import json, os, sys
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
CORE = JDEQ / "CORE"
sys.path.insert(0, str(CORE))
sys.path.insert(0, str(CORE / "reference_router"))
sys.path.insert(0, str(CORE / "version_validator"))
sys.path.insert(0, str(CORE / "virtual_daemon"))
sys.path.insert(0, str(CORE / "audit_logger"))

def check_ssot():
    ssot_dir = JDEQ / "SSOT"
    blueprint = JDEQ / "BLUEPRINT_v22.md"
    if ssot_dir.exists() and blueprint.exists():
        return {"status": "ONLINE", "integrity": "INTACT"}
    return {"status": "COMPROMISED", "integrity": "DEGRADED"}

def check_reference_router():
    try:
        from reference_router import ReferenceRouter
        rr = ReferenceRouter()
        return {"status": "ONLINE", "database": str(rr.db)}
    except Exception as e:
        return {"status": "OFFLINE", "error": str(e)}

def check_event_bus():
    try:
        from event_bus import EventBus
        eb = EventBus()
        subscriber_count = sum(len(subs) for subs in eb.subscribers.values())
        return {"status": "ONLINE", "subscribers": subscriber_count, "queue_size": eb.queue.qsize()}
    except Exception as e:
        return {"status": "OFFLINE", "error": str(e)}

def check_virtual_daemon():
    try:
        from vdaemon import VirtualDaemon
        vd = VirtualDaemon()
        active = vd.list_active()
        return {"status": "ONLINE", "active_daemons": len(active), "max_concurrent": vd.max_concurrent}
    except Exception as e:
        return {"status": "OFFLINE", "error": str(e)}

def check_version_validator():
    try:
        from version_validator import VersionValidator
        vv = VersionValidator()
        return {"status": "ONLINE", "database": str(vv.c)}
    except Exception as e:
        return {"status": "OFFLINE", "error": str(e)}

def check_identity_engine():
    try:
        from identity_engine import IdentityEngine
        ie = IdentityEngine()
        identity = ie.get_identity()
        if identity.get("status") == "NOT_FOUND":
            return {"status": "COMPROMISED"}
        return {"status": "ONLINE", "uuid": identity.get("uuid", "UNKNOWN")[:8] + "..."}
    except Exception as e:
        return {"status": "OFFLINE", "error": str(e)}

def check_audit_logger():
    try:
        from audit_logger import AuditLogger
        al = AuditLogger()
        integrity = al.verify_integrity()
        recent = al.read(3)
        return {"status": "ONLINE", "integrity": integrity, "recent_entries": len(recent)}
    except Exception as e:
        return {"status": "OFFLINE", "error": str(e)}

def check_system_resources():
    mem = {}
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if "MemTotal" in line:
                    mem["total_mb"] = int(line.split()[1]) // 1024
                if "MemAvailable" in line:
                    mem["available_mb"] = int(line.split()[1]) // 1024
    except:
        mem = {"total_mb": 0, "available_mb": 0}
    return mem

def generate_report():
    return {
        "timestamp": datetime.now().isoformat(),
        "system": "MICO-JDEQ COMMAND CENTER",
        "components": {
            "ssot": check_ssot(),
            "reference_router": check_reference_router(),
            "event_bus": check_event_bus(),
            "virtual_daemon": check_virtual_daemon(),
            "version_validator": check_version_validator(),
            "identity_engine": check_identity_engine(),
            "audit_logger": check_audit_logger()
        },
        "resources": check_system_resources()
    }

if __name__ == "__main__":
    print(json.dumps(generate_report(), indent=2))
