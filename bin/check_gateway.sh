#!/bin/bash
if bash -n "$HOME/JDEQ/mico_gateway.sh" 2>/dev/null; then
    echo "ONLINE"
else
    echo "ERROR"
fi
