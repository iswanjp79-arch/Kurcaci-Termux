#!/usr/bin/env python3
class PolicyEngine:
    def check(self, confidence): return {"status":"APPROVED" if confidence>=80 else "REJECTED"}
