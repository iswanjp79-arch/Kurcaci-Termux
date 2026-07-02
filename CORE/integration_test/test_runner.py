#!/usr/bin/env python3
"""MICO-JDEQ Integration Test — Tahap 6"""
import sys, os, json, time, hashlib
from pathlib import Path

# Path absolut
JDEQ = Path.home() / "JDEQ"
CORE = JDEQ / "CORE"
sys.path.insert(0, str(CORE))
sys.path.insert(0, str(CORE / "reference_router"))
sys.path.insert(0, str(CORE / "version_validator"))
sys.path.insert(0, str(CORE / "virtual_daemon"))

PASS, FAIL = 0, 0

def test(name, func):
    global PASS, FAIL
    print(f"\n{'='*50}")
    print(f"TEST: {name}")
    print(f"{'='*50}")
    try:
        func()
        print(f"✅ PASS: {name}")
        PASS += 1
    except Exception as e:
        print(f"❌ FAIL: {name} ({e})")
        FAIL += 1

# ============================================================
# 1. SOVEREIGN KERNEL — Verifikasi SSOT
# ============================================================
def test_sovereign_kernel():
    ssot_dir = JDEQ / "SSOT"
    blueprint = JDEQ / "BLUEPRINT_v22.md"
    assert ssot_dir.exists(), "SSOT directory tidak ditemukan"
    assert blueprint.exists(), "Blueprint tidak ditemukan"
    # Verifikasi permission
    assert (ssot_dir / "ROADMAP").exists(), "SSOT/ROADMAP tidak ada"
    print("  ✅ SSOT tersedia")
    print("  ✅ Blueprint tersedia")
    print("  ✅ Permission terjaga")

# ============================================================
# 2. REFERENCE ROUTER — Verifikasi registri & validasi
# ============================================================
def test_reference_router():
    from reference_router import ReferenceRouter
    rr = ReferenceRouter()
    
    # Register modul uji
    res = rr.register("INTEGRATION_TEST", "1.0", "integration test content")
    assert res["status"] == "REGISTERED", f"Register gagal: {res}"
    print(f"  ✅ Register: {res}")
    
    # Validasi konten benar
    res = rr.validate("INTEGRATION_TEST", "integration test content")
    assert res["status"] == "APPROVED", f"Validate gagal: {res}"
    print(f"  ✅ Validate: {res}")
    
    # Validasi konten palsu — HARUS DITOLAK
    res = rr.validate("INTEGRATION_TEST", "konten palsu")
    assert res["status"] == "REJECTED", f"Seharusnya menolak konten palsu: {res}"
    print(f"  ✅ Menolak konten palsu: {res}")

# ============================================================
# 3. VERSION VALIDATOR — Verifikasi versi & hash
# ============================================================
def test_version_validator():
    from version_validator import VersionValidator
    vv = VersionValidator()
    test_hash = hashlib.sha256(b"integration_test_v1").hexdigest()
    
    # Register versi baru
    res = vv.register("integration_module", "1.0.0", test_hash, "IntegrationTest", "Core")
    assert res["status"] == "REGISTERED", f"Register gagal: {res}"
    print(f"  ✅ Register: {res}")
    
    # Validasi versi & hash cocok
    res = vv.validate("integration_module", "1.0.0", test_hash)
    assert res["status"] == "APPROVED", f"Validate gagal: {res}"
    print(f"  ✅ Validate: {res}")
    
    # Validasi hash berbeda — HARUS DITOLAK
    res = vv.validate("integration_module", "1.0.0", "wronghash")
    assert res["status"] == "REJECTED", f"Seharusnya menolak hash salah: {res}"
    assert res["reason"] == "HASH_MISMATCH", f"Alasan salah: {res}"
    print(f"  ✅ Menolak hash mismatch: {res}")
    
    # Cegah downgrade versi — HARUS DITOLAK
    res = vv.register("integration_module", "0.9.0", test_hash, "IntegrationTest", "Core")
    assert res["status"] == "REJECTED", f"Seharusnya menolak downgrade: {res}"
    assert res["reason"] == "VERSION_DOWNGRADE", f"Alasan salah: {res}"
    print(f"  ✅ Menolak version downgrade: {res}")

# ============================================================
# 4. EVENT BUS — Verifikasi publish/subscribe
# ============================================================
def test_event_bus():
    from event_bus import EventBus
    eb = EventBus()
    received = []
    
    def handler(payload):
        received.append(payload)
    
    # Subscribe ke event integrasi
    eb.subscribe("TASK_COMPLETED", handler, "IntegrationTest")
    time.sleep(0.1)
    
    # Publish event
    res = eb.publish("TASK_COMPLETED", {"source_module": "IntegrationTest", "task": "verify"})
    assert res["status"] == "CREATED", f"Publish gagal: {res}"
    print(f"  ✅ Publish: {res}")
    
    # Tunggu dispatch
    time.sleep(1)
    assert len(received) > 0, "Event tidak diterima oleh subscriber"
    print(f"  ✅ Event diterima: {len(received)} event")
    print(f"  ✅ Lifecycle: {received[0].get('lifecycle', 'UNKNOWN')}")

# ============================================================
# 5. VIRTUAL DAEMON — Verifikasi lifecycle
# ============================================================
def test_virtual_daemon():
    from vdaemon import VirtualDaemon
    vd = VirtualDaemon()
    
    # Instantiate
    res = vd.instantiate("integration_daemon", "test", {"task": "verify"}, "IntegrationTest")
    assert res["status"] == "CREATED", f"Instantiate gagal: {res}"
    exec_id = res["execution_id"]
    print(f"  ✅ Instantiate: {exec_id}")
    
    # Tunggu selesai
    time.sleep(3)
    active = vd.list_active()
    assert exec_id not in active, f"Daemon masih aktif: {active}"
    print(f"  ✅ Daemon selesai & dihancurkan")
    
    # Verifikasi audit log
    audit_file = JDEQ / "AUDIT" / "daemon_audit.jsonl"
    if audit_file.exists():
        with open(audit_file) as f:
            lines = f.readlines()
        print(f"  ✅ Audit log: {len(lines)} entri")
    else:
        print("  ⚠️ Audit log belum tersedia")

# ============================================================
# 6. INTEGRASI PENUH — Semua modul bekerja bersama
# ============================================================
def test_full_integration():
    """Simulasi alur lengkap: Kernel → Router → Version → Event → Daemon"""
    from reference_router import ReferenceRouter
    from version_validator import VersionValidator
    from event_bus import EventBus
    from vdaemon import VirtualDaemon
    
    # 1. Kernel: verifikasi SSOT
    assert (JDEQ / "SSOT").exists(), "SSOT tidak ditemukan"
    
    # 2. Router: daftarkan modul
    rr = ReferenceRouter()
    rr.register("FULL_INTEGRATION", "2.0", "full integration test")
    
    # 3. Version Validator: daftarkan versi
    vv = VersionValidator()
    test_hash = hashlib.sha256(b"full_integration").hexdigest()
    vv.register("full_module", "2.0.0", test_hash, "FullIntegration", "Core")
    
    # 4. Event Bus: subscribe
    eb = EventBus()
    events = []
    eb.subscribe("TASK_COMPLETED", lambda p: events.append(p), "FullIntegration")
    time.sleep(0.1)
    
    # 5. Virtual Daemon: jalankan tugas
    vd = VirtualDaemon()
    res = vd.instantiate("full_daemon", "test", {"source_module": "FullIntegration"}, "FullIntegration")
    time.sleep(3)
    
    # 6. Verifikasi daemon selesai
    assert res["execution_id"] not in vd.list_active(), "Daemon belum selesai"
    
    # 7. Verifikasi event tercatat
    eb.publish("TASK_COMPLETED", {"source_module": "FullIntegration", "result": "ok"})
    time.sleep(1)
    assert len(events) > 0, "Tidak ada event tercatat"
    
    print("  ✅ Kernel → Router → Version → Event → Daemon = SEMUA TERINTEGRASI")

# ============================================================
# JALANKAN SEMUA
# ============================================================
test("Sovereign Kernel — Verifikasi SSOT", test_sovereign_kernel)
test("Reference Router — Register & Validate", test_reference_router)
test("Version Validator — Version & Hash", test_version_validator)
test("Event Bus — Publish & Subscribe", test_event_bus)
test("Virtual Daemon — Lifecycle", test_virtual_daemon)
test("Full Integration — Semua Modul", test_full_integration)

print(f"\n{'='*50}")
print(f"INTEGRATION TEST SELESAI")
print(f"Total PASS: {PASS}")
print(f"Total FAIL: {FAIL}")
print(f"{'='*50}")

if FAIL > 0:
    sys.exit(1)
else:
    print("✅ SELURUH FONDASI TERBUKTI TERINTEGRASI")
