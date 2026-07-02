import os, sys, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
sys.path.insert(0, os.path.join(JDEQ, "CORE_REASONING"))
from engineering_rule_engine import engineering_reasoning

def mico_assistant(user_input):
    """MICO sebagai asisten teknik otonom terbatas."""
    print("\n" + "="*55)
    print("  MICO ENGINEERING AUTONOMOUS ASSISTANT")
    print("="*55)
    
    # 1. Reasoning
    print("[1/3] Menganalisa input...")
    reasoning = engineering_reasoning(user_input)
    
    # 2. Validation
    print("[2/3] Memvalidasi hasil...")
    sys.path.insert(0, os.path.join(JDEQ, "CORE_VALIDATION"))
    from validation_engine import validate_reasoning_result
    validation = validate_reasoning_result(reasoning)
    
    # 3. Output final
    print("[3/3] Menyusun rekomendasi...")
    
    print("\n[MICO FINAL OUTPUT]")
    print(f"  DATA        : {reasoning.get('input', user_input)[:100]}...")
    print(f"  ANALISA     : {reasoning.get('analysis', {}).get('classification', 'General')}")
    print(f"  VALIDASI    : {validation.get('status', 'UNCHECKED')}")
    print(f"  KEPUTUSAN   : {reasoning.get('decision', 'N/A')}")
    
    # Tambah rekomendasi tindakan
    if validation.get('status') == 'PASS':
        print(f"  REKOMENDASI : Hasil valid, bisa lanjut ke Approval Gate.")
    else:
        print(f"  REKOMENDASI : Perlu review manual. Issues: {validation.get('issues', [])}")
    
    print("="*55)
    print("[MICO] Analisa selesai. Keputusan akhir tetap di Mas Iswan.")
    
    return {
        "reasoning": reasoning,
        "validation": validation,
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    # Test dengan contoh input
    test_input = "Analisa RAB beton proyek K-225 volume 28.5 m3 biaya 1200000"
    mico_assistant(test_input)
