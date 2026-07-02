# System Maintenance SOP
- **Orphan cleanup:** find ~/JDEQ -type f -name "*.pyc" -delete (hati-hati)
- **Cache cleanup:** rm -rf ~/JDEQ/tmp/* (aman)
- **Log rotation:** daemon/log_rotate.sh (jika tersedia)
- **Temp cleanup:** ~/JDEQ/tmp/
- **Zombie process:** pkill -f runsv, pkill -f defunct
- **Duplicate detector:** architecture_checker
- **Storage optimizer:** performance_monitor
