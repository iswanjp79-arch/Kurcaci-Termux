import os, json, re
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
SSOT_RULES = os.path.join(JDEQ, "CORE_PROTOCOL/CORE_RULE.md")
VALIDATION_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/validation.log")

def load_ssot_rules():
    """Muat aturan validasi dari SSOT."""
    rules = {
        "max_volume_m3": 1000,
        "max_cost_per_item": 1_000_000_000,
        "allowed_mutu_beton": ["K-225", "K-250", "K-300", "K-350"],
        "required_fields_rab": ["volume_m3", "biaya_rp"]
    }
    if os.path.isfile(SSOT_RULES):
        with open(SSOT_RULES) as f:
            content = f.read()
            # Ekstrak aturan sederhana dari markdown
            vol_match = re.search(r'max_volume[:\s]+(\d+)', content)
            if vol_match:
                rules["max_volume_m3"] = int(vol_match.group(1))
    return rules

def validate_reasoning_result(reasoning_output):
    """Validasi hasil reasoning terhadap aturan SSOT."""
    rules = load_ssot_rules()
    issues = []
    
    if not isinstance(reasoning_output, dict):
        return {"status": "REJECT", "issues": ["Format output tidak valid"]}
    
    analysis = reasoning_output.get("analysis", {})
    
    # Cek 1: Klasifikasi harus ada
    if "classification" not in analysis:
        issues.append("Klasifikasi tidak ditemukan")
    
    # Cek 2: Data numerik divalidasi batas
    extracted = analysis.get("extracted_data", {})
    if "volume_m3" in extracted:
        for vol in extracted["volume_m3"]:
            try:
                if float(vol) > rules["max_volume_m3"]:
                    issues.append(f"Volume {vol} m3 melebihi batas {rules['max_volume_m3']}")
            except ValueError:
                issues.append(f"Volume tidak valid: {vol}")
    
    if "mutu_beton" in extracted:
        for mutu in extracted["mutu_beton"]:
            mutu_str = f"K-{mutu}"
            if mutu_str not in rules["allowed_mutu_beton"]:
                issues.append(f"Mutu beton {mutu_str} di luar standar: {rules['allowed_mutu_beton']}")
    
    # Cek 3: Biaya masuk akal
    if "biaya_rp" in extracted:
        for biaya in extracted["biaya_rp"]:
            try:
                nilai = float(biaya.replace(".", "").replace(",", ""))
                if nilai > rules["max_cost_per_item"]:
                    issues.append(f"Biaya Rp {biaya} melebihi batas per item")
            except:
                pass
    
    # Tentukan status
    if not issues:
        status = "PASS"
    elif len(issues) <= 2:
        status = "HOLD"
    else:
        status = "REJECT"
    
    result = {
        "status": status,
        "issues": issues,
        "rules_checked": list(rules.keys()),
        "validated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    
    # Log
    with open(VALIDATION_LOG, "a") as f:
        f.write(f"[{result['validated_at']}] VALIDATION [{status}] {json.dumps(issues)}\n")
    
    return result

if __name__ == "__main__":
    # Test
    test = {
        "analysis": {
            "classification": "CIVIL - RAB",
            "extracted_data": {
                "volume_m3": ["28.5", "120"],
                "mutu_beton": ["225"],
                "biaya_rp": ["1.200.000", "85.000"]
            }
        }
    }
    result = validate_reasoning_result(test)
    print(f"[VALIDATION] Status: {result['status']}")
    if result['issues']:
        print(f"  Issues: {result['issues']}")
