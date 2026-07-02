# KONSTITUSI JDEQ — DECISION KERNEL
**Versi:** 1.0
**Status:** LOCKED — Seluruh Dewan Agen tunduk pada Konstitusi ini

## PRINSIP UTAMA
Decision Kernel adalah lapisan tertinggi. Tidak ada agen yang dapat memutuskan sendiri.
Semua input (event, prompt, perubahan sistem) WAJIB melewati Decision Kernel.

## ALUR KEPUTUSAN
0. INPUT → (Event / Prompt / Perubahan)
1. STATE CHECK (10) → Baca kondisi sistem saat ini
2. SELF QUESTION (5) → Hasilkan hipotesis
3. CROSS VALIDATION (3) → Minimal 3 sudut pandang
4. ASSEMBLY (1) → Keputusan dikunci oleh sistem
5. POST AUDIT (5) → Log, rollback, evidence, update memory
6. WORKFLOW → Pilih agen (DeepSeek/Claude/ChatGPT/dll)
7. EKSEKUSI → Agen bekerja
8. AUDIT → Verifikasi hasil
