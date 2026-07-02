import os, json, time
from pathlib import Path

B = Path.home() / "JDEQ"
INDEX_FILE = B / "KERNEL" / "index" / "master_index.json"
FOLDERS = ["SSOT", "GOVERNANCE", "CORTEX", "KERNEL", "ASSEMBLY", "queue", "scripts", "ANANDA_MADINA"]

def build_index():
    index = {}
    for folder in FOLDERS:
        folder_path = B / folder
        if folder_path.exists():
            index[folder] = []
            for root, dirs, files in os.walk(folder_path):
                for file in files:
                    full_path = Path(root) / file
                    index[folder].append({
                        "name": file,
                        "path": str(full_path.relative_to(B)),
                        "size": full_path.stat().st_size
                    })
    os.makedirs(INDEX_FILE.parent, exist_ok=True)
    with open(INDEX_FILE, "w") as f:
        json.dump(index, f, indent=2)
    return len(index)

if __name__ == "__main__":
    count = build_index()
    print(f"✅ Index Daemon: {count} folder terindeks")
    print(f"   File: {INDEX_FILE}")
