#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
echo "# MICO-JDEQ Report $(date)" > /tmp/mico_report.md
bash "$BIN/mico_audit.sh" >> /tmp/mico_report.md 2>&1
echo "Report: /tmp/mico_report.md"
