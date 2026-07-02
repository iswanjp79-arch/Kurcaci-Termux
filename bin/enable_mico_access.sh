#!/data/data/com.termux/files/usr/bin/bash
# Aktivasi akses total MICO ke Termux & bridge Android

sed -i 's/ALLOWED_PATHS = \[.*\]/ALLOWED_PATHS = ["\/data\/data\/com\.termux\/files"]/' ~/JDEQ/mico_chat.py

# Tambahkan fungsi bridge jika belum ada
if ! grep -q "def list_apps" ~/JDEQ/mico_chat.py; then
    cat >> ~/JDEQ/mico_chat.py << 'EOL'

def list_apps():
    try:
        result = subprocess.check_output("pm list packages -f", shell=True, text=True)
        apps = [line.split("=")[-1].strip() for line in result.splitlines() if "=" in line]
        return "\n".join(apps[:50]) if apps else "Tidak ada aplikasi"
    except Exception as e:
        return f"[ERROR] {e}"

def launch_app(package):
    try:
        subprocess.check_output(f"monkey -p {package} 1", shell=True, stderr=subprocess.STDOUT)
        return f"✅ Aplikasi {package} diluncurkan"
    except Exception as e:
        return f"[ERROR] {e}"
EOL
fi

# Restart executive loop & watchdog
pkill -f "executive_loop.py"
nohup python3 ~/JDEQ/bin/executive_loop.py > ~/JDEQ/logs/executive_loop.log 2>&1 &
pkill -f "watchdog.sh"
nohup ~/JDEQ/bin/watchdog.sh > /dev/null 2>&1 &

echo "✅ MICO akses total & bridge aktif"
