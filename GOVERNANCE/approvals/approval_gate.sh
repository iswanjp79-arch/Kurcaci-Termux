#!/bin/bash
# Approval Gate – setiap perubahan arsitektur harus disetujui
APPROVAL_FILE="$HOME/JDEQ/GOVERNANCE/approvals/pending_approval.txt"
if [ -f "$APPROVAL_FILE" ]; then
  echo "⏳ Ada perubahan yang menunggu persetujuan:"
  cat "$APPROVAL_FILE"
  echo ""
  echo "Setujui dengan: rm $APPROVAL_FILE"
else
  echo "✅ Tidak ada perubahan yang menunggu persetujuan."
fi
