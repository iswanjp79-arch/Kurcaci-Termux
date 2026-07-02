import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
DOC_DIR = os.path.join(JDEQ, "CORE_KNOWLEDGE/documents")
INDEX_FILE = os.path.join(JDEQ, "CORE_KNOWLEDGE/index/knowledge_index.json")

def load_documents():
    """Pindai folder dokumen dan ekstrak metadata."""
    index = []
    categories = ["civil", "mep", "maintenance", "quality"]
    
    for cat in categories:
        cat_path = os.path.join(DOC_DIR, cat)
        if not os.path.isdir(cat_path):
            continue
        for file_name in os.listdir(cat_path):
            file_path = os.path.join(cat_path, file_name)
            if not os.path.isfile(file_path):
                continue
            
            # Ambil metadata
            stat = os.stat(file_path)
            ext = os.path.splitext(file_name)[1].lower()
            
            entry = {
                "file_name": file_name,
                "file_path": file_path,
                "category": cat,
                "extension": ext,
                "size_kb": round(stat.st_size / 1024, 1),
                "modified": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S"),
                "loaded_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            
            # Baca isi file teks sederhana
            if ext in [".txt", ".md", ".json", ".csv"]:
                try:
                    with open(file_path, "r", errors="ignore") as f:
                        entry["preview"] = f.read()[:500]
                except:
                    entry["preview"] = "(tidak bisa dibaca)"
            else:
                entry["preview"] = f"(file {ext})"
            
            index.append(entry)
            print(f"[LOADER] {file_name} → {cat}")
    
    # Simpan index
    with open(INDEX_FILE, "w") as f:
        json.dump(index, f, indent=2, default=str)
    
    print(f"[LOADER] {len(index)} dokumen terindex")
    return index

if __name__ == "__main__":
    load_documents()
