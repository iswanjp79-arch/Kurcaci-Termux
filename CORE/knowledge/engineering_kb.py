import os, json

JDEQ = "/data/data/com.termux/files/home/JDEQ"
KB_FILE = os.path.join(JDEQ, "CORE_KNOWLEDGE/index/engineering_kb.json")

# Kategori standar JDEQ
DEFAULT_KB = {
    "civil": {
        "rab": {"template": "Rencana Anggaran Biaya", "format": ["boq", "ahsp", "volume", "harga_satuan"]},
        "boq": {"template": "Bill of Quantity", "format": ["item", "volume", "satuan"]},
        "ahsp": {"template": "Analisa Harga Satuan Pekerjaan", "format": ["koefisien", "bahan", "upah"]},
        "drawing": {"template": "Gambar Teknik", "format": ["denah", "potongan", "detail"]},
        "material": {"template": "Spesifikasi Material", "format": ["mutu", "dimensi", "standar"]}
    },
    "mep": {
        "electrical": {"template": "Instalasi Listrik", "format": ["daya", "kabel", "panel"]},
        "mechanical": {"template": "Sistem Mekanikal", "format": ["ducting", "fan", "cooling"]},
        "plumbing": {"template": "Plumbing", "format": ["pipa", "pompa", "sanitasi"]},
        "hvac": {"template": "HVAC", "format": ["ac", "ventilasi", "refrigerant"]}
    },
    "maintenance": {
        "preventive": {"template": "Preventive Maintenance", "format": ["jadwal", "checklist", "frekuensi"]},
        "corrective": {"template": "Corrective Maintenance", "format": ["kerusakan", "perbaikan", "part"]},
        "failure_analysis": {"template": "Failure Analysis", "format": ["root_cause", "impact", "solution"]}
    },
    "quality": {
        "iso": {"template": "ISO Standards", "format": ["9001", "31000", "45001"]},
        "ohsas": {"template": "OHSAS 18001", "format": ["hazard", "risk", "control"]},
        "audit": {"template": "Audit Report", "format": ["temuan", "koreksi", "verifikasi"]}
    }
}

def init_kb():
    """Inisialisasi Knowledge Base."""
    if not os.path.isfile(KB_FILE):
        with open(KB_FILE, "w") as f:
            json.dump(DEFAULT_KB, f, indent=2)
        print(f"[KB] Engineering Knowledge Base dibuat")
    else:
        print(f"[KB] Knowledge Base sudah ada")

def search_kb(keyword):
    """Cari di Knowledge Base."""
    with open(KB_FILE) as f:
        kb = json.load(f)
    
    results = []
    for cat, subcats in kb.items():
        for sub, info in subcats.items():
            if keyword.lower() in sub.lower() or keyword.lower() in str(info).lower():
                results.append({"category": cat, "subcategory": sub, "info": info})
    return results

if __name__ == "__main__":
    init_kb()
    # Test search
    res = search_kb("rab")
    print(f"[KB] Pencarian 'rab': {len(res)} hasil")
    for r in res:
        print(f"  - {r['category']}/{r['subcategory']}: {r['info']['template']}")
