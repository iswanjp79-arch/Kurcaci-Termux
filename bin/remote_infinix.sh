#!/data/data/com.termux/files/usr/bin/bash
# Remote control Infinix via SSH port 8022
ssh -o StrictHostKeyChecking=no -p 8022 100.103.39.81 "$*" 2>/dev/null
