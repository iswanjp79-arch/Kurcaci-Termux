import os, json, re
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
KB_FILE = os.path.join(JDEQ, "CORE_KNOWLEDGE/index/engineering_kb.json")
INDEX_FILE = os.path.join(JDEQ, "CORE_KNOWLEDGE/index/knowledge_index.json")
DECISION_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.json")

def log_decision(input_text, analysis, decision, status):
    """Catat keputusan ke decision memory."""
    entry = {
        "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "input": input_text[:200],
        "analysis": analysis[:300],
        "decision": decision[:200],
        "status": status
    }
    data = []
    if os.path.isfile(DECISION_LOG):
        with open(DECISION_LOG) as f:
            try:
                data = json.load(f)
            except:
                data = []
    data.append(entry)
    with open(DECISION_LOG, "w") as f:
        json.dump(data, f, indent=2)

def extract_numbers(text):
    """Ekstrak angka dan satuan dari teks."""
    patterns = [
        (r'(\d+\.?\d*)\s*m3', 'volume_m3'),
        (r'(\d+\.?\d*)\s*m2', 'luas_m2'),
        (r'(\d+\.?\d*)\s*m', 'panjang_m'),
        (r'(\d+\.?\d*)\s*kg', 'berat_kg'),
        (r'Rp\s*([\d,.]+)', 'biaya_rp'),
        (r'(\d+\.?\d*)\s*mm', 'dimensi_mm'),
        (r'Beton\s*K-(\d+)', 'mutu_beton'),
        (r'Beton\s*(\d+)\s*MPa', 'mutu_beton_mpa'),
    ]
    hasil = {}
    for pattern, key in patterns:
        matches = re.findall(pattern, text, re.IGNORECASE)
        if matches:
            hasil[key] = [m.strip() if isinstance(m, str) else m for m in matches]
    return hasil

def analyze_rab(text):
    """Analisa teks RAB."""
    nums = extract_numbers(text)
    analysis = []
    
    # Volume pekerjaan
    if 'volume_m3' in nums:
        analysis.append(f"Volume beton/galian: {', '.join(nums['volume_m3'])} m3")
    if 'luas_m2' in nums:
        analysis.append(f"Luas pekerjaan: {', '.join(nums['luas_m2'])} m2")
    
    # Biaya
    if 'biaya_rp' in nums:
        total = nums['biaya_rp']
        analysis.append(f"Nilai pekerjaan: Rp {', '.join(total)}")
    
    # Mutu beton
    if 'mutu_beton' in nums:
        analysis.append(f"Mutu beton: K-{', '.join(nums['mutu_beton'])}")
    
    # Klasifikasi
    classification = "CIVIL - RAB Analysis"
    if 'galian' in text.lower() or 'tanah' in text.lower():
        classification += " (Earthwork)"
    if 'beton' in text.lower() or 'cor' in text.lower():
        classification += " (Concrete)"
    
    return {
        "classification": classification,
        "extracted_data": nums,
        "summary": "; ".join(analysis) if analysis else "Data numerik terbatas"
    }

def analyze_maintenance(text):
    """Analisa teks maintenance."""
    keywords_failure = ['rusak', 'gagal', 'mati', 'bocor', 'getar', 'panas', 'bising']
    keywords_action = ['ganti', 'perbaiki', 'cek', 'inspeksi', 'lubrikasi']
    
    found_failures = [w for w in keywords_failure if w in text.lower()]
    found_actions = [w for w in keywords_action if w in text.lower()]
    
    analysis = {
        "classification": "MAINTENANCE - Failure Analysis",
        "symptoms": found_failures,
        "recommended_actions": found_actions,
        "severity": "MEDIUM" if len(found_failures) > 2 else "LOW"
    }
    return analysis

def analyze_mep(text):
    """Analisa teks MEP."""
    nums = extract_numbers(text)
    analysis = {
        "classification": "MEP",
        "extracted_data": nums,
        "summary": "Analisa MEP - data teknis terdeteksi" if nums else "Data MEP minimal"
    }
    if 'daya' in text.lower() or 'listrik' in text.lower() or 'watt' in text.lower():
        analysis["classification"] += " (Electrical)"
    if 'pipa' in text.lower() or 'plumbing' in text.lower():
        analysis["classification"] += " (Plumbing)"
    return analysis

def engineering_reasoning(input_text, context="general"):
    """Engine utama penalaran engineering."""
    
    # Tentukan tipe analisa berdasarkan kata kunci
    text_lower = input_text.lower()
    
    if any(w in text_lower for w in ['rab', 'anggaran', 'biaya', 'boq', 'beton', 'galian']):
        result = analyze_rab(input_text)
    elif any(w in text_lower for w in ['rusak', 'gagal', 'mati', 'maintenance', 'pm', 'corrective']):
        result = analyze_maintenance(input_text)
    elif any(w in text_lower for w in ['listrik', 'pipa', 'mep', 'hvac', 'plumbing', 'daya']):
        result = analyze_mep(input_text)
    else:
        result = {"classification": "GENERAL", "summary": "Konteks tidak spesifik, analisa terbatas"}
    
    # Format output MICO
    output = {
        "input": input_text[:200],
        "analysis": result,
        "risk": "LOW" if result.get("severity", "LOW") == "LOW" else "MEDIUM",
        "recommendation": "Verifikasi data lapangan" if not result.get("extracted_data") else "Data numerik tersedia untuk analisa lanjut",
        "decision": result.get("classification", "GENERAL"),
        "status": "PASS"
    }
    
    # Log ke decision memory
    log_decision(input_text, str(result), output["decision"], output["status"])
    
    return output

if __name__ == "__main__":
    # Test
    test_input = "Analisa RAB beton proyek K-225 volume 28.5 m3 biaya 1200000"
    hasil = engineering_reasoning(test_input)
    print("[REASONING] Analisa selesai")
    print(f"  Klasifikasi: {hasil['analysis'].get('classification','?')}")
    print(f"  Data: {hasil['analysis'].get('extracted_data',{})}")
    print(f"  Keputusan: {hasil['decision']}")
