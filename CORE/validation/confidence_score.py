import os, json

def calculate_confidence(extracted_data, validation_issues):
    """Hitung skor keyakinan 0-100 berdasarkan kelengkapan data dan isu validasi."""
    score = 100
    
    # Kurangi berdasarkan isu validasi
    score -= len(validation_issues) * 15
    
    # Kurangi jika data numerik minim
    if not extracted_data or len(extracted_data) == 0:
        score -= 30
    elif len(extracted_data) < 2:
        score -= 10
    
    # Batasi 0-100
    return max(0, min(100, score))

def confidence_label(score):
    if score >= 80:
        return "HIGH"
    elif score >= 50:
        return "MEDIUM"
    else:
        return "LOW"

if __name__ == "__main__":
    # Test
    data = {"volume_m3": ["28.5"], "mutu_beton": ["225"]}
    issues = ["Volume mendekati batas"]
    score = calculate_confidence(data, issues)
    print(f"[CONFIDENCE] Score: {score}/100 ({confidence_label(score)})")
