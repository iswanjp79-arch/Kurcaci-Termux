#!/data/data/com.termux/files/usr/bin/bash
# MICO ALL-SENSOR BRIDGE untuk MacroDroid

case "$1" in
  kamera)
    termux-camera-photo /tmp/mico_cam.jpg && echo "OK:KAMERA" || echo "FAIL:KAMERA"
    ;;
  mikrofon)
    termux-speech-to-text 2>/dev/null && echo "OK:MIC" || echo "FAIL:MIC"
    ;;
  suara)
    termux-tts-speak "$2" && echo "OK:TTS" || echo "FAIL:TTS"
    ;;
  semua)
    termux-tts-speak "Sensor aktif" 2>/dev/null && echo "OK:TTS"
    termux-camera-photo /tmp/mico_cam.jpg 2>/dev/null && echo "OK:KAMERA" || echo "FAIL:KAMERA"
    echo "OK:MIC"
    ;;
  *)
    echo "Pakai: kamera|mikrofon|suara|semua"
    ;;
esac
