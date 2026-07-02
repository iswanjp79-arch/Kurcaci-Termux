#!/bin/bash
PENDING="$HOME/JDEQ/GOVERNANCE/pending_approval.txt"
if [ -f "$PENDING" ]; then
  echo "⏳ Ada perubahan yang menunggu persetujuan:"
  cat "$PENDING"
  echo "Setujui dengan: rm $PENDING"
else
  echo "✅ Tidak ada perubahan yang menunggu persetujuan."
fi
