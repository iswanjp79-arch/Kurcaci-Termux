#!/bin/bash
# Rolling Key Engine + Anti-Detection
KEY_FILE="$HOME/JDEQ/VAULT/keys/all_keys.env"
random_delay() {
  local min=${1:-0.5}; local max=${2:-2}
  delay=$(echo "scale=2; $min + ($RANDOM % 1000)/1000 * ($max - $min)" | bc)
  sleep "$delay"
}
random_ua() {
  ua_list=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15"
    "Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36"
  )
  echo "${ua_list[$((RANDOM % ${#ua_list[@]}))]}"
}
safe_curl() {
  local url="$1"; local data="$2"; local method="${3:-POST}"; local key="$4"
  local ua=$(random_ua)
  random_delay 0.3 1.5
  if [ -n "$key" ]; then
    curl -s -X "$method" "$url" -H "User-Agent: $ua" -H "Authorization: Bearer $key" -H "Content-Type: application/json" -d "$data" 2>/dev/null
  else
    curl -s -X "$method" "$url" -H "User-Agent: $ua" -H "Content-Type: application/json" -d "$data" 2>/dev/null
  fi
}
export -f random_delay random_ua safe_curl
