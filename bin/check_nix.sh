#!/bin/bash
if [ -f "$HOME/storage/shared/NixBridge/result.txt" ]; then
    echo "CONNECTED"
else
    echo "UNKNOWN"
fi
