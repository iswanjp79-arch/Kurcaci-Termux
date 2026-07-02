#!/usr/bin/env python3
import json, sys
NODES = {"sensor":"local","vision":"local","voice":"local","report":"local","audit":"local"}
def dispatch(capability):
    node = NODES.get(capability, "unknown")
    return {"capability": capability, "node": node, "status": "dispatched"}
if __name__ == "__main__":
    print(f"Dispatch: {json.dumps(dispatch(sys.argv[1] if len(sys.argv) > 1 else 'audit'), indent=2)}")
    print("✅ Node Dispatcher aktif")
