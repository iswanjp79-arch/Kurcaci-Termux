#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
FREE=$(df -h /data/data/com.termux/files/home | tail -1 | awk '{print $4}')
log "INFO" "Storage free: $FREE"; exit 0
