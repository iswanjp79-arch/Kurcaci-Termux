import os, json, re
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
INDEX_FILE = os.path.join(JDEQ, "CORE_KNOWLEDGE/index/knowledge_index.json")
PARSED_DIR = os.path.join(JDEQ, "CORE_KNOWLEDGE/index/parsed")

def extract_text(file_path, ext):
    """Ekstrak teks dari berbagai format file."""
    text = ""
    try:
        if ext in [".txt", ".md", ".csv", ".json"]:
            with open(file_path, "r", errors="ignore") as f:
                text = f.read()
        elif ext == ".py":
            with open(file_path, "r", errors="ignore") as f:
                text = f.read()
        else:
            text = f"[BINARY] {ext} – butuh parser khusus"
    except Exception as e:
        text = f"[ERROR] {str(e)}"
    return text[:2000]  # Batasi 2000 karakter

def classify_content(text, file_name):
    """Klasifikasi konten berdasarkan kata kunci."""
    text_lower = text.lower()
    categories = {
        "civil": ["rab", "boq", "ahsp", "beton", "tanah", "pondasi", "struktur", "baja"],
        "mep": ["listrik", "pipa", "ac", "hvac", "plumbing", "elektrikal"],
        "maintenance": ["preventive", "corrective", "inspeksi", "checklist", "pm"],
        "quality": ["iso", "ohsas", "audit", "qc", "quality", "sop"]
    }
    
    scores = {}
    for cat, keywords in categories.items():
        scores[cat] = sum(1 for kw in keywords if kw in text_lower)
    
    best = max(scores, key=scores.get) if max(scores.values()) > 0 else "uncategorized"
    return best, scores

if __name__ == "__main__":
    os.makedirs(PARSED_DIR, exist_ok=True)
    
    if not os.path.isfile(INDEX_FILE):
        print("[PARSER] Index belum ada, jalankan knowledge_loader dulu")
        exit(1)
    
    with open(INDEX_FILE) as f:
        documents = json.load(f)
    
    results = []
    for doc in documents:
        text = extract_text(doc["file_path"], doc.get("extension", ""))
        category, scores = classify_content(text, doc.get("file_name", ""))
        
        parsed = {
            **doc,
            "extracted_text": text[:500],
            "auto_category": category,
            "category_scores": scores,
            "parsed_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        results.append(parsed)
        print(f"[PARSER] {doc['file_name']} → {category}")
    
    # Simpan hasil parsing
    parsed_file = os.path.join(PARSED_DIR, f"parsed_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
    with open(parsed_file, "w") as f:
        json.dump(results, f, indent=2, default=str)
    
    print(f"[PARSER] {len(results)} dokumen diparse → {parsed_file}")
