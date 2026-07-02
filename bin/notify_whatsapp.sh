#!/data/data/com.termux/files/usr/bin/bash
# WhatsApp via termux-sms-send (SMS gateway)
termux-sms-send -n "0895360979857" "$*" 2>/dev/null && echo "✅ SMS terkirim" || {
  # Fallback: termux-share untuk WhatsApp
  echo "$*" | termux-share -a send 2>/dev/null && echo "✅ Share WA terbuka" || echo "⚠️ Notifikasi manual"
}
