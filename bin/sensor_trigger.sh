#!/data/data/com.termux/files/usr/bin/bash
# MICO Sensor Trigger - dipanggil MacroDroid via Termux
LOG="$HOME/JDEQ/logs/sensor.log"
echo "[$(date)] Trigger diterima: $*" >> $LOG

case "$1" in
    kamera)
        echo "/analyst /deepdive /report Foto diterima" | python3 $HOME/JDEQ/router/slash_engine.py >> $LOG
        ;;
    mikrofon)
        echo "/notes /summary /action Rekaman diterima" | python3 $HOME/JDEQ/router/slash_engine.py >> $LOG
        ;;
    triple_tap)
        echo "/open boq /start inspection" | python3 $HOME/JDEQ/router/slash_engine.py >> $LOG
        ;;
    *)
        echo "/ghost Sensor $1 aktif" | python3 $HOME/JDEQ/router/slash_engine.py >> $LOG
        ;;
esac
