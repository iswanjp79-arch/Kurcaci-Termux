#!/data/data/com.termux/files/usr/bin/python3
"""
JDEQ MICO ROUTER — Peta Kamus Regex 100 Perintah
Lokal dulu, cloud hanya jika diperlukan.
Batas riwayat: 20 entri.
"""
import re, json, os, sys, time, requests

# ============================================================
# 100 SLASH COMMANDS
# ============================================================
SLASH_COMMANDS = {
    "/toneformal": "Gunakan tone formal, profesional, dan sopan.",
    "/tonecasual": "Gunakan tone casual, santai, dan akrab.",
    "/persuasive": "Gunakan tone persuasif dan meyakinkan.",
    "/data": "Sertakan data, statistik, dan fakta pendukung.",
    "/examplesonly": "Berikan contoh saja, tanpa teori.",
    "/noexamples": "Jangan berikan contoh.",
    "/limit": "Batasi jawaban maksimal {args} kata.",
    "/expandpoints": "Perluas setiap poin dengan penjelasan detail.",
    "/bullet": "Gunakan format bullet points.",
    "/nobullet": "Gunakan format paragraf, tanpa bullet.",
    "/startup": "Berikan ide startup inovatif di bidang {args}.",
    "/gtm": "Buat go-to-market plan untuk produk {args}.",
    "/monetize": "Berikan ide monetisasi untuk {args}.",
    "/validate": "Validasi ide bisnis: {args}.",
    "/icp": "Tentukan ideal customer profile (ICP) untuk {args}.",
    "/sales": "Buat sales pitch untuk produk {args}.",
    "/colddm": "Tulis cold outreach message untuk {args}.",
    "/offer": "Buat penawaran menarik untuk {args}.",
    "/funnel": "Rancang funnel strategy untuk {args}.",
    "/retention": "Berikan ide retensi pelanggan untuk {args}.",
    "/ghost": "Jawab singkat, tanpa penjelasan tambahan.",
    "/minimal": "Jawab sependek mungkin.",
    "/brief": "Jawab maksimal 3-5 baris.",
    "/expand": "Berikan penjelasan super detail.",
    "/stepbystep": "Jelaskan langkah demi langkah.",
    "/checklist": "Buat checklist actionable.",
    "/framework": "Gunakan framework terstruktur.",
    "/blueprint": "Buat blueprint implementasi.",
    "/playbook": "Buat playbook sistem repeatable.",
    "/roadmap": "Buat roadmap berbasis timeline.",
    "/linkedin": "Tulis LinkedIn post tentang {args}.",
    "/twitter-thread": "Buat Twitter thread tentang {args}.",
    "/script": "Tulis script video/reel tentang {args}.",
    "/hook": "Buat opening line yang kuat untuk {args}.",
    "/story": "Tulis dalam format storytelling tentang {args}.",
    "/carousel": "Buat konten carousel slide-wise untuk {args}.",
    "/headlines": "Berikan opsi judul ganda untuk {args}.",
    "/captions": "Buat caption sosmed untuk {args}.",
    "/viral": "Tulis dengan style high-engagement untuk {args}.",
    "/authority": "Gunakan tone expert/authority untuk {args}.",
    "/debug": "Cari bug di kode: {args}.",
    "/refactor": "Rapikan kode: {args}.",
    "/optimizecode": "Optimasi performa kode: {args}.",
    "/systemdesign": "Design arsitektur sistem untuk {args}.",
    "/api": "Buat struktur API untuk {args}.",
    "/database": "Design database untuk {args}.",
    "/scalability": "Berikan approach scaling untuk {args}.",
    "/security": "Lakukan security check pada {args}.",
    "/testcases": "Generate test cases untuk {args}.",
    "/pseudocode": "Tulis pseudocode untuk {args}.",
    "/learn": "Jelaskan topik {args} secara mendalam.",
    "/resources": "Berikan resource terbaik untuk belajar {args}.",
    "/practice": "Buat soal latihan untuk {args}.",
    "/quiz": "Buat quiz untuk menguji pengetahuan {args}.",
    "/mistakes": "Sebutkan kesalahan umum dalam {args}.",
    "/summary": "Ringkas topik {args}.",
    "/revision": "Buat revisi cepat untuk {args}.",
    "/notes": "Buat catatan terstruktur untuk {args}.",
    "/examples": "Berikan contoh nyata dari {args}.",
    "/explainwhy": "Jelaskan reasoning di balik {args}.",
    "/analyst": "Analisis secara mendalam: {args}.",
    "/critic": "Cari kekurangan dari: {args}.",
    "/optimizer": "Improve yang sudah ada: {args}.",
    "/simplify": "Jelaskan dengan sederhana: {args}.",
    "/eli5": "Jelaskan seperti ke anak 5 tahun: {args}.",
    "/deepdive": "Lakukan deep dive super detail: {args}.",
    "/compare": "Bandingkan opsi: {args}.",
    "/proscons": "Sebutkan pros & cons: {args}.",
    "/firstprinciples": "Pecah ke dasar pertama: {args}.",
    "/contrarian": "Challenge ide: {args}.",
    "/plan": "Buat daily plan.",
    "/weekly": "Buat weekly plan.",
    "/prioritize": "Prioritaskan task: {args}.",
    "/focus": "Hilangkan distraction untuk {args}.",
    "/automate": "Ide otomasi untuk {args}.",
    "/delegate": "Yang bisa di-delegate: {args}.",
    "/habits": "Bantu bangun habit: {args}.",
    "/track": "Buat sistem tracking untuk {args}.",
    "/timeblock": "Time blocking untuk {args}.",
    "/review": "Buat weekly review.",
    "/resume": "Perbaiki resume untuk posisi {args}.",
    "/interview": "Q&A interview untuk {args}.",
    "/mockinterview": "Simulasi interview untuk {args}.",
    "/hr": "Jawaban HR round untuk {args}.",
    "/portfolio": "Ide portfolio project untuk {args}.",
    "/roadmapcareer": "Career roadmap untuk {args}.",
    "/jobsearch": "Strategi job search untuk {args}.",
    "/referral": "Pesan referral untuk {args}.",
    "/salary": "Negosiasi gaji untuk posisi {args}.",
    "/skills": "Skill yang perlu dipelajari untuk {args}.",
    "/headline": "Ide headline LinkedIn untuk {args}.",
    "/profile": "Review profile LinkedIn untuk {args}.",
    "/bio": "Rewrite bio untuk {args}.",
    "/contentplan": "Content calendar untuk {args}.",
    "/niche": "Perjelas niche untuk {args}.",
    "/audience": "Target audience untuk {args}.",
    "/positioning": "Brand positioning untuk {args}.",
    "/engagement": "Naikin engagement untuk {args}.",
    "/dms": "DM strategy untuk {args}.",
    "/growth": "Growth strategy untuk {args}.",
}

# ============================================================
# KONFIGURASI
# ============================================================
MAX_HISTORY = 20
HISTORY_FILE = os.path.expanduser("~/JDEQ/logs/chat_history.json")

def load_history():
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE) as f:
            return json.load(f)
    return []

def save_history(history):
    if len(history) > MAX_HISTORY:
        history = history[-MAX_HISTORY:]
    with open(HISTORY_FILE, 'w') as f:
        json.dump(history, f, indent=2)

def query_cloud(prompt):
    from cloud_agent import call_gemini
    return call_gemini(prompt)

def query_local_llm(prompt):
    """Kirim prompt ke LLM lokal (Qwen) di port 8082."""
    try:
        r = requests.post(
            "http://127.0.0.1:8082/v1/chat/completions",
            json={
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": 256,
                "temperature": 0.1
            },
            timeout=60
        )
        if r.status_code == 200:
            data = r.json()
            return data['choices'][0]['message']['content'].strip()
    except Exception as e:
        pass
    return None

def route(user_input):
    """Fungsi routing utama."""
    history = load_history()
    
    # Deteksi slash command
    match = re.match(r'^(/\w+)\s*(.*)', user_input)
    
    if match:
        cmd = match.group(1)
        args = match.group(2).strip()
        
        if cmd in SLASH_COMMANDS:
            template = SLASH_COMMANDS[cmd]
            if "{args}" in template and args:
                template = template.replace("{args}", args)
            elif "{args}" in template and not args:
                template = template.replace("{args}", "")
            
            # Coba lokal dulu
            response = query_local_llm(template)
            result = response if response else f"[CLOUD] Maaf, LLM lokal tidak tersedia untuk perintah {cmd}."
        else:
            result = f"Perintah {cmd} tidak dikenal. Gunakan /help untuk daftar perintah."
    else:
        # Input biasa — teruskan ke LLM lokal
        response = query_local_llm(user_input)
        result = response if response else "LLM lokal tidak tersedia. Coba lagi nanti."
    
    # Simpan riwayat
    history.append({"role": "user", "content": user_input})
    history.append({"role": "assistant", "content": result})
    save_history(history)
    
    return result

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(route(" ".join(sys.argv[1:])))
    else:
        print("MICO Router siap. Ketik perintah atau /help.")
