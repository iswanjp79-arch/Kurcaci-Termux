import os, json, sys

JDEQ = "/data/data/com.termux/files/home/JDEQ"
sys.path.insert(0, os.path.join(JDEQ, "CORE_REASONING"))
from engineering_rule_engine import engineering_reasoning

def query_with_reasoning(question):
    """Query yang langsung menjalankan reasoning."""
    hasil = engineering_reasoning(question)
    
    # Format output MICO
    print("\n[MICO ANALYSIS]")
    print(f"DATA     : {hasil['input']}")
    
    if isinstance(hasil['analysis'], dict):
        analysis = hasil['analysis']
        if 'classification' in analysis:
            print(f"ANALISA  : {analysis['classification']}")
        if 'summary' in analysis:
            print(f"RINGKASAN: {analysis['summary']}")
        if 'extracted_data' in analysis and analysis['extracted_data']:
            print(f"DATA TEKNIS: {json.dumps(analysis['extracted_data'], indent=2)}")
        if 'symptoms' in analysis and analysis['symptoms']:
            print(f"GEJALA   : {', '.join(analysis['symptoms'])}")
    else:
        print(f"ANALISA  : {hasil['analysis']}")
    
    print(f"RISIKO   : {hasil['risk']}")
    print(f"REKOMENDASI: {hasil['recommendation']}")
    print(f"KEPUTUSAN: {hasil['decision']}")
    
    return hasil

if __name__ == "__main__":
    print("[QUERY+REASONING] MICO Engineering Reasoning Ready")
    
    # Test
    test_q = "Analisa RAB beton proyek"
    print(f"\nInput: '{test_q}'")
    query_with_reasoning(test_q)
    
    # Cek decision memory
    dec_log = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.json")
    if os.path.isfile(dec_log):
        with open(dec_log) as f:
            data = json.load(f)
        print(f"\n[DECISION MEMORY] {len(data)} keputusan tersimpan")
