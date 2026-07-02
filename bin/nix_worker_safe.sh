#!/data/data/com.termux/files/usr/bin/bash
# Nix Worker Safe — Hanya eksekusi perintah yang diizinkan
ALLOWED_COMMANDS=(
    "ls" "cat" "echo" "grep" "awk" "sed -i.bak"
    "python3 ~/JDEQ/CORE/orchestrator.py"
    "python3 ~/JDEQ/MICO_COGNITIVE/event_engine.py"
    "python3 ~/JDEQ/bridge/ghost_relay.py"
)
CMD="$1"
for allowed in "${ALLOWED_COMMANDS[@]}"; do
    if [[ "$CMD" == "$allowed"* ]]; then
        eval "$CMD"
        exit 0
    fi
done
echo "PERINTAH DITOLAK: $CMD" >&2
exit 1
