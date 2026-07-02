#!/bin/bash
echo "Updating MICO-JDEQ..."
cd ~/JDEQ/REPOSITORY && git pull 2>/dev/null
echo "Update complete. Run RUN_MICO.sh to verify."
