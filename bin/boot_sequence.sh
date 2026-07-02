#!/data/data/com.termux/files/usr/bin/bash
# MICO Boot Sequence — Anchor System
echo "$(date): MICO BOOT SEQUENCE" >> ~/JDEQ/logs/boot.log

# 1. Load Constitution
echo "  📜 Load Constitution..."
[ -f ~/JDEQ/config/mico_constitution.json ] && echo "  ✅ Constitution loaded" || echo "  ❌ Constitution missing"

# 2. Load SSOT
echo "  🔒 Load SSOT..."
[ -f ~/JDEQ/SSOT/MICO-EQ-001-FINAL.md ] && echo "  ✅ SSOT loaded" || echo "  ❌ SSOT missing"

# 3. Load Memory
echo "  🧠 Load Memory..."
[ -f ~/JDEQ/config/memory.json ] && echo "  ✅ Memory loaded" || echo "  ❌ Memory missing"

# 4. Check Schedule
echo "  📅 Check Schedule..."
crontab -l 2>/dev/null | grep -c 'JDEQ' && echo "  ✅ Schedule active" || echo "  ⚠️  No schedule"

# 5. Check Notifications
echo "  📬 Check Notifications..."
ls ~/JDEQ/INBOX/ 2>/dev/null | wc -l | xargs echo "  📨 Inbox:"

# 6. Standby
echo "  🟢 MICO Standby"
