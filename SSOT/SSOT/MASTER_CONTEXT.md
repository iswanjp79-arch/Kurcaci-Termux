# JDEQ MASTER CONTEXT
Versi: 1.1 | Tanggal: 2026-06-22 | Pemilik: Iswan Juman Pancoro, ST

---
## FAKTA PERMANEN

### Hardware
- Perangkat: Vivo Y28 (V2352)
- SoC: Helio G85 | RAM: 4GB | Android: 13 | Kernel: 5.10
- Termux: 0.119.0-beta.3 (F-Droid) | ABI: arm64-v8a
- Thermal limit JDEQ: 40°C | Swap: 8GB zram

### Model AI Lokal
- Qwen2.5-3B-Instruct-Q4_K_M.gguf
- Path: ~/models/core/
- Server: llama-server port 8082
- Parameter aman: --ctx-size 512 -t 2 --no-warmup

### Arsitektur JDEQ
- Root: ~/JDEQ/
- SSOT: ~/JDEQ/SSOT/MASTER.md
- Entry point MICO: mico_chat_final.py
- Symlink aktif: mico_chat_active.py → mico_chat_final.py
- Supervisor: supervisor_light.sh (cron */10)
- Cron aktif: backup Minggu 02:00, dlq */10, event */5,
              healthcheck */10, mqtt tiap jam

### Agen Aktif
- ChatGPT = Chief Architect
- Claude   = Chief Auditor (bukan eksekutor)
- DeepSeek = Field Engineer / Executor
- Copilot  = Integration Planner
- Gemini   = Jarvis / Advisor
- DOLA     = SSOT Keeper

### Doktrin
- Local First | Human Authority Absolute
- Audit Before Action | No Kill Without Confirm
- Stabilitas > Fitur | Bukti > Opini

---
## STATE SESI TERAKHIR (update tiap sesi)

- Tanggal: 2026-06-22
- llama-server: PID 4751, port 8082, aktif
- supervisor_light.sh: aktif + cron
- MQTT: STATUS BELUM TERVERIFIKASI
- whisper_dummy.sh: belum terhubung ke binary nyata
- stt/tts: masih dummy script
- Audio test berhasil: ~/JDEQ/audio-test/suara-mas-iwan.wav
- cmake: broken (ABI mismatch jsoncpp 1.9.8 vs cmake 4.3.3)
- whisper-cli binary: ADA di sistem_otak/llama_stabil/build/bin/
- Phase JDEQ: 2.5 (Foundation 90%, Integration 40%)

---
## CELAH YANG BELUM DISELESAIKAN

1. MQTT belum diverifikasi aktif
2. whisper_dummy.sh belum terhubung ke binary nyata
3. supervisor_light.sh belum ada MAX_RESTART
4. Cron overlap: healthcheck_jdeq.sh + supervisor_light.sh
5. Symlink mico.gguf di ANANDA_MADINA rusak (placeholder)
6. eval "$CMD" di nix_worker = RCE vulnerability, belum dipatch
7. CORE_ORCHESTRATION/ tidak ada di filesystem aktual

---
## PELAJARAN PENTING (jangan diulang)

- duckdb via pip = gagal (android_lf.h tidak ada)
- torch dari PyTorch index = tidak ada wheel ARM64
- n8n terlalu berat untuk Y28 (butuh 512MB+)
- cmake 4.3.3 tidak bisa dipakai (jsoncpp mismatch)
- Jangan build dari source jika ada pre-built binary
- Developer Mode harus ON sebelum operasi build apapun
