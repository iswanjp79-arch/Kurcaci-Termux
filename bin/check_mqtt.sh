#!/bin/bash
if pgrep -f "mosquitto" > /dev/null; then
    echo "ONLINE"
else
    echo "OFFLINE"
fi
