#!/data/data/com.termux/files/usr/bin/bash
[ $# -gt 0 ] && termux-tts-speak "$*" || termux-tts-speak "$(cat)"
