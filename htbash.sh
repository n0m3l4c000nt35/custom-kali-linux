#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW="\e[33m"
GRAY="\e[90m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET='\033[0m'

API_URL="https://labs.hackthebox.com/api/v4"
APP_TOKEN=$(cat $HOME/.config/htb/htbash.conf)
HTB_MACHINES_DIR="$HOME/htb/machines"
MACHINES_JSON="$HOME/.config/htb/machines/machines.json"
VPN_CONFIG="$HOME/.config/htb/vpn"

fetch_active_machines() {
    local base_url="$API_URL/machine/paginated?retired=0&page="
    local all_data="[]"
    local last_page
    last_page=$(curl -s "${base_url}1" -H "Authorization: Bearer $APP_TOKEN" | jq -r '.meta.last_page')

    for (( page=1; page<=last_page; page++ )); do
        local page_data
        page_data=$(curl -s "${base_url}${page}" -H "Authorization: Bearer $APP_TOKEN" | jq -r '.data')
        all_data=$(jq -s 'add' <(echo "$all_data") <(echo "$page_data"))
    done

    echo "$all_data"
}

fetch_retired_machines() {
    local base_url="$API_URL/machine/list/retired/paginated?page="
    local all_data="[]"
    local last_page
    last_page=$(curl -s "${base_url}1" -H "Authorization: Bearer $APP_TOKEN" | jq -r '.meta.last_page')

    for (( page=1; page<=last_page; page++ )); do
        local page_data
        page_data=$(curl -s "${base_url}${page}" -H "Authorization: Bearer $APP_TOKEN" | jq -r '.data')
        all_data=$(jq -s 'add' <(echo "$all_data") <(echo "$page_data"))
    done

    echo "$all_data"
}

get_all_machines(){
  local active_machines retired_machines all_machines

  active_machines=$(fetch_active_machines)
  retired_machines=$(fetch_retired_machines)

  all_machines=$(jq -s 'add' <(echo "$active_machines") <(echo "$retired_machines"))
}

update_machines() {
    local active_count retired_count total_count

    all_machines=$(get_all_machines)
    
    active_count=$(echo "$active_machines" | jq 'length')
    retired_count=$(echo "$retired_machines" | jq 'length')
    total_count=$(echo "$all_machines" | jq 'length')

    echo "$all_machines" > "$MACHINES_JSON"

    echo
    echo -e "[${GREEN}MACHINES UPDATED${RESET}]"
    echo
    echo -e "[${YELLOW}TOTAL ACTIVE MACHINES${RESET}] $active_count"
    echo -e "[${YELLOW}TOTAL RETIRED MACHINES${RESET}] $retired_count"
    echo -e "[${YELLOW}TOTAL MACHINES SAVED${RESET}] $total_count"
    echo
    echo -e "[${YELLOW}DATA SAVED TO${RESET}] $MACHINES_JSON"
}

list_machines(){
  echo
  headers=("Name" "OS" "Free" "Difficulty")

  mapfile -t rows < <(jq -r --arg os "" --arg difficulty "" '.[] | select(($os == "" or ($os | ascii_downcase) == (.os | ascii_downcase)) and ($difficulty == "" or ($difficulty | ascii_downcase) == (.difficultyText | ascii_downcase))) | [.name, .os, (.free | tostring), .difficultyText] | @tsv' "$MACHINES_JSON")

  col_widths=()
  for i in "${!headers[@]}"; do
    col_widths[i]=${#headers[i]}
  done

  for row in "${rows[@]}"; do
  IFS=$'\t' read -r col1 col2 col3 col4 <<< "$row"
    [[ ${#col1} -gt ${col_widths[0]} ]] && col_widths[0]=${#col1}
    [[ ${#col2} -gt ${col_widths[1]} ]] && col_widths[1]=${#col2}
    [[ ${#col3} -gt ${col_widths[2]} ]] && col_widths[2]=${#col3}
    [[ ${#col4} -gt ${col_widths[3]} ]] && col_widths[3]=${#col4}
  done

  center_text() {
    local text="$1"
    local width="$2"
    local pad=$(( (width - ${#text}) / 2 ))
    printf "%*s%s%*s" $pad "" "$text" $((width - pad - ${#text})) ""
  }

  separator="+"
  for w in "${col_widths[@]}"; do
    separator+=$(printf '%0.s-' $(seq 1 $((w + 2))))
    separator+="+"
  done

  title="Hack The Box Machines"
  title_length=${#title}
  echo $title_length

  total_width=1
  for w in "${col_widths[@]}"; do
    total_width=$((total_width + w + 3))
  done

  echo "$separator"
  printf "| %*s%*s|\n" $(( (total_width - 2 + title_length) / 2 )) "$title" $(( (total_width - 2 - title_length) / 2 )) ""

  echo "$separator"
  printf "|"
  for i in "${!headers[@]}"; do
    printf " %s |" "$(center_text "${headers[i]}" "${col_widths[i]}")"
  done

  echo
  echo "$separator"

  for row in "${rows[@]}"; do
  IFS=$'\t' read -r col1 col2 col3 col4 <<< "$row"
  printf "| %-*s | %-*s | %-*s | %-*s |\n" \
    "${col_widths[0]}" "$col1" \
    "${col_widths[1]}" "$col2" \
    "${col_widths[2]}" "$col3" \
    "${col_widths[3]}" "$col4"
  done

  echo "$separator"
}

get_machine_info(){
  machine_name=$1
  response=$(curl -s "$API_URL/machine/profile/$machine_name" -H "Authorization: Bearer $APP_TOKEN" | jq '.info')
  echo
  echo -e "${GREEN}Machine name${RESET}:" $(echo "$response" | jq -r '.name')
  echo -e "${GREEN}OS${RESET}:" $(echo "$response" | jq -r '.os')
  echo -e "${GREEN}Status${RESET}:" $(echo "$response" | jq -r 'if .active then "Active" else "Retired" end')
  echo -e "${GREEN}Release date${RESET}:" $(echo "$response" | jq -r '.release | sub("\\.\\d{3}Z$"; "Z") | fromdate | strftime("%d-%m-%Y")')
  echo -e "${GREEN}Points${RESET}:" $(echo "$response" | jq -r '.points')
  echo -e "${GREEN}User Owns${RESET}:" $(echo "$response" | jq -r '.user_owns_count')
  echo -e "${GREEN}Root Owns${RESET}:" $(echo "$response" | jq -r '.root_owns_count')
  echo -e "${GREEN}Stars${RESET}:" $(echo "$response" | jq -r '.stars')
  echo -e "${GREEN}Avatar${RESET}: https://www.hackthebox.com"$(echo "$response" | jq -r '.avatar')
  echo -e "${GREEN}Difficulty${RESET}:" $(echo "$response" | jq -r '.difficultyText')
  echo -e "${GREEN}Synopsis${RESET}:" $(echo "$response" | jq -r '.synopsis')
}

if [ $# -eq 0 ]; then
  echo
  echo -e "[${GREEN}?${NC}] Help panel"
  exit 0
fi

while getopts "uli:" opt 2>/dev/null; do
  case $opt in
    u) update_machines;;
    l) list_machines;;
    i) get_machine_info "$OPTARG";;
    \?) echo -e "\n[${@:OPTIND-1:1}] ${GREEN}Help panel${RESET}";;
  esac
done

exit 0
