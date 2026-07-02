import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
AUDIT_TRACE = os.path.join(JDEQ, "CORE_MEMORY/logs/audit_trace.json")

def audit_decision(input_text, reasoning_result, validation_result):
    """Audit lengkap: input → reasoning → validation → keputusan final."""
    entry = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "input_summary": input_text[:150],
        "reasoning_classification": reasoning_result.get("analysis", {}).get("classification", "UNKNOWN"),
        "reasoning_decision": reasoning_result.get("decision", "UNKNOWN"),
        "validation_status": validation_result.get("status", "UNCHECKED"),
        "validation_issues": validation_result.get("issues", []),
        "final_status": validation_result.get("status", "HOLD"),
        "reason": f"Validasi {'lulus' if validation_result.get('status') == 'PASS' else 'tertahan: ' + ', '.join(validation_result.get('issues', []))}"
    }
    
    # Simpan ke audit trace
    data = []
    if os.path.isfile(AUDIT_TRACE):
        with open(AUDIT_TRACE) as f:
            try:
                data = json.load(f)
            except:
                data = []
    data.append(entry)
    with open(AUDIT_TRACE, "w") as f:
        json.dump(data, f, indent=2, default=str)
    
    print(f"[AUDITOR] Keputusan final: {entry['final_status']}")
    print(f"[AUDITOR] Alasan: {entry['reason']}")
    return entry

if __name__ == "__main__":
    print("[DECISION AUDITOR] Siap")
