#!/usr/bin/env python3
def run_tests():
    results=[]
    try:
        from reference_router.reference_router import ReferenceRouter
        r=ReferenceRouter()
        r.register("TEST","1.0","test content")
        v=r.validate("TEST","test content")
        results.append(("ReferenceRouter","PASS" if v["status"]=="APPROVED" else "FAIL"))
    except Exception as e:
        results.append(("ReferenceRouter",f"FAIL:{e}"))
    
    try:
        from virtual_daemon.vdaemon import VirtualDaemon
        v=VirtualDaemon()
        v.run("test","TEST_EVENT")
        results.append(("VirtualDaemon","PASS" if len(v.p)==0 else "FAIL"))
    except Exception as e:
        results.append(("VirtualDaemon",f"FAIL:{e}"))
    
    return results
