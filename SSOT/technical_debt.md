# JDEQ TECHNICAL DEBT REGISTER
| ID | TAHAP | DESKRIPSI | ROOT CAUSE | STATUS |
|----|-------|-----------|------------|--------|
| TD-001 | 1 | sv melaporkan sshd down, padahal proses hidup dan port 8022 berfungsi. | runsvdir tidak berjalan. sshd dijalankan manual. | MITIGATED (startup script) |
| TD-002 | 2 | 11 service tidak relevan menyebabkan lock contention dan crash. | Service asing tidak dikelola, berebut lock. | CLOSED (dipindahkan) |
| TD-003 | 2 | runsvdir tidak dapat dijalankan tanpa risiko crash. | Lingkungan service tidak bersih + keterbatasan Termux. | MITIGATED (diganti startup script) |
| TD-004 | 6 | MQTT anonymous & non‑persistent. | Konfigurasi default Mosquitto. | CLOSED (password & persistensi terpasang) |

**Total Technical Debt: 0 TERBUKA**
