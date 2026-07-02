# PROTOKOL ASSEMBLY POINT 10–5–3–1+5
**Versi:** 1.0
**Status:** LOCKED — Seluruh Dewan Agen terikat protokol ini

## LEVEL 10 — EVIDENCE LOCK (10 BUKTI WAJIB)
Setiap klaim "SELESAI" wajib memiliki minimal:
1. Proses (skrip/code)
2. Log (bukti eksekusi)
3. Arsitektur (sesuai blueprint)
4. Komunikasi (jika multi-agent)
5. Persistensi (data tersimpan)
6. Recovery (pemulihan teruji)
7. Audit (tercatat di SSOT)
8. Performa (tidak crash/leak)
9. Integrasi (bekerja dengan modul lain)
10. Reproduksi (bisa diulang)

## LEVEL 5 — ASSEMBLY POINT
Semua output agen (Claude, DeepSeek, ChatGPT, dll) wajib melewati:
Tidak ada file langsung masuk JDEQ tanpa Assembly Point.

## LEVEL 3 — FINAL GATE
Sebelum PASS, wajib lolos:
1. Architecture Review
2. Runtime Verification
3. Evidence Verification

Jika satu gagal → status "DRAFT", bukan "PASS".

## LEVEL 1 — SSOT FINAL
Hanya satu sumber kebenaran:

## +5 PERTANYAAN MANDIRI (SEBELUM KODE)
1. Apa tujuan sebenarnya?
2. Apa bukti keberhasilannya?
3. Apa risiko implementasinya?
4. Bagaimana cara mengaudit hasilnya?
5. Bagaimana rollback jika gagal?

**Aturan Mutlak:** Tidak boleh ada kode sebelum 5 pertanyaan dijawab.
