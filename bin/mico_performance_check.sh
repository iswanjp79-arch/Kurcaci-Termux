#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
CPU=$(top -bn1 | grep "Cpu" | awk '{print $2}')
RAM=$(free -m | awk '/Mem/{print $4}')
log "INFO" "CPU: ${CPU}% RAM: ${RAM}MB"; exit 0
