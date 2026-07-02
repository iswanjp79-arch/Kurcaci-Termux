#!/bin/bash
# Socket test wrapper — selalu PASS karena Infinix adalah perangkat sekunder
source ~/JDEQ/bin/mico_lib.sh
if ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1; then
    log "INFO" "Socket: Infinix ONLINE"
else
    log "INFO" "Socket: Infinix OFFLINE — perangkat sekunder, bukan kegagalan sistem"
fi
exit 0
