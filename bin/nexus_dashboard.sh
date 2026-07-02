#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║   MICO-JDEQ NEXUS COMMAND CENTER v2.0              ║
# ║   Coder: DeepSeek Executor for MICO-JDEQ           ║
# ╚══════════════════════════════════════════════════════╝

# Definisi Warna Mewah
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[38;5;208m'
PINK='\033[38;5;206m'
PURPLE='\033[38;5;99m'
TEAL='\033[38;5;37m'
NC='\033[0m' # No Color

# Fungsi Status
show_status() {
    if eval "$2" 2>/dev/null; then
        echo -e "${GREEN}●${NC}"
    else
        echo -e "${RED}●${NC}"
    fi
}

show_online() {
    if eval "$1" 2>/dev/null; then
        echo -e "${GREEN}✅ ONLINE${NC}"
    else
        echo -e "${RED}⛔ OFFLINE${NC}"
    fi
}

# Loop Utama
while true; do
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}🛡️  MICO-JDEQ NEXUS DASHBOARD   ${NC}  ${CYAN}│${NC}  ${YELLOW}$(date '+%d %b %Y %H:%M:%S')${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"

    # Baris 1: LLM & Node.js Bridge
    echo -e "${CYAN}║${NC} ${MAGENTA}🧠 LLM MICO (8082)${NC}   │ Status: $(show_online "pgrep llama-server > /dev/null") ${CYAN}│${NC} ${BLUE}🌉 Node Bridge (9090)${NC} │ Status: $(show_online "pgrep -f pocketpal_node.js > /dev/null") ${CYAN}║${NC}"
    
    # Baris 2: Groq & Infinix
    echo -e "${CYAN}║${NC} ${ORANGE}☁️  Groq Cloud${NC}      │ Status: $(show_online "curl -s --max-time 5 https://api.groq.com/openai/v1/models | grep -q 'id'") ${CYAN}│${NC} ${PINK}📱 Infinix (Relay)${NC} │ Status: $(show_online "ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1") ${CYAN}║${NC}"

    # Baris 3: Symthink & Dual Control
    echo -e "${CYAN}║${NC} ${PURPLE}🔀 Symthink Router${NC}│ Status: $(show_online "[ -f ~/JDEQ/router/symthink_router.py ]") ${CYAN}│${NC} ${TEAL}🔄 Dual Control${NC}    │ Status: $(show_online "curl -s --max-time 5 -X POST http://100.103.39.81:9000 -d '{}' | grep -q 'result'") ${CYAN}║${NC}"

    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"

    # Metrik Kinerja
    RAM_FREE=$(free -m | awk '/Mem/{printf "%.0f", $7}')
    DISK_USED=$(df -h ~ | awk 'NR==2 {print $5}')
    TEMP_CPU=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.1f", $1/1000}' || echo "N/A")
    BATTERY=$(termux-battery-status 2>/dev/null | grep percentage | awk -F: '{print $2}' | tr -d ' ,' || echo "N/A")

    echo -e "${CYAN}║${NC} ${WHITE}⚡ Metrik Sistem${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    RAM Bebas    : ${GREEN}${RAM_FREE} MB${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    Penyimpanan  : ${YELLOW}${DISK_USED} Terpakai${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    Suhu CPU     : ${RED}${TEMP_CPU}°C${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    Baterai      : ${GREEN}${BATTERY}%${NC}                                                ${CYAN}║${NC}"

    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"

    # Audit Trail Ringkas
    echo -e "${CYAN}║${NC} ${WHITE}📋 Log Audit Terbaru${NC}                                                          ${CYAN}║${NC}"
    tail -n 2 ~/JDEQ/logs/audit_trail.log 2>/dev/null | while read line; do
        echo -e "${CYAN}║${NC}   ${line:0:62}${CYAN}║${NC}"
    done

    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}[ Refresh otomatis 5 detik | Tekan Ctrl+C untuk keluar ]${NC}"
    sleep 5
done
