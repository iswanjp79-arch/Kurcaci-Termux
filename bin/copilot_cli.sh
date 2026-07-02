#!/data/data/com.termux/files/usr/bin/bash
# MICO Copilot CLI Wrapper
PROMPT="$*"
if [ -z "$PROMPT" ]; then
  echo "Pakai: copilot_cli.sh <pertanyaan koding>"
  exit 1
fi

echo "🧑‍💻 Copilot CLI: memproses..."
# Gunakan gh copilot jika tersedia
if command -v gh &>/dev/null && gh copilot --version &>/dev/null; then
  gh copilot suggest "$PROMPT" 2>/dev/null || echo "⚠️ Copilot CLI gagal"
else
  echo "⚠️ GitHub CLI (gh) belum terpasang. Install: pkg install gh"
fi
