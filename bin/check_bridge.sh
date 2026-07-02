#!/bin/bash
if [ -x "$HOME/JDEQ/CORE_BRIDGE/send_to_nix.sh" ]; then
    echo "ONLINE"
else
    echo "OFFLINE"
fi
