#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\e[33m'
GRAY='\e[90m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
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
  local active_machines retired_machines all_machines active_count retired_count total_count

  active_machines=$(fetch_active_machines)
  retired_machines=$(fetch_retired_machines)

  all_machines=$(jq -s 'add' <(echo "$active_machines") <(echo "$retired_machines"))

  echo "$all_machines" > "$MACHINES_JSON"

  active_count=$(echo "$active_machines" | jq 'length')
  retired_count=$(echo "$retired_machines" | jq 'length')
  total_count=$(echo "$all_machines" | jq 'length')

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
  local os="$1"
  local difficulty="$2"
  local status="$2"

  echo
  headers=("Name" "OS" "Free" "Difficulty")

  mapfile -t rows < <(jq -r --arg os "$os" --arg difficulty "$difficulty" '.[] | select(($os == "" or ($os | ascii_downcase) == (.os | ascii_downcase)) and ($difficulty == "" or ($difficulty | ascii_downcase) == (.difficultyText | ascii_downcase))) | [.name, .os, (.free | tostring), .difficultyText] | @tsv' "$MACHINES_JSON")

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
  local machine_name=$1
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
  echo -e "[${GREEN}?${RESET}] Help panel"
  exit 0
fi

flag_u=0
flag_l=0
flag_i=0

machine_name=""
os_filter=""
difficulty_filter=""

valid_os=("linux" "windows")
valid_difficulties=("easy" "medium" "hard" "insane")

errors=()

is_valid_value() {
  local value="$1"
  shift
  local list=("$@")
  for item in "${list[@]}"; do
    [[ "$item" == "$value" ]] && return 0
  done
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u)
      flag_u=1
      shift
      ;;
    -l)
      flag_l=1
      shift
      ;;
    -i)
      if [[ -n "$2" && "$2" != -* ]]; then
        flag_i=1
        machine_name="$2"
        shift 2
      else
        echo -e "\n[${RED}!${RESET}] Missing machine name after -i"
        exit 1
      fi
      ;;
    --os)
      if [[ -n "$2" && "$2" != -* ]]; then
        value=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        if is_valid_value "$value" "${valid_os[@]}"; then
          os_filter="$value"
          shift 2
        else
          errors+=("[${RED}!${RESET}] Invalid OS: ${RED}$2${RESET}. Valid values are: ${BLUE}${valid_os[*]}${RESET}")
          shift 2
        fi
      else
        errors+=("[${RED}!${RESET}] Missing OS after --os")
        shift
      fi
      ;;
    --difficulty)
      if [[ -n "$2" && "$2" != -* ]]; then
        value=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        if is_valid_value "$value" "${valid_difficulties[@]}"; then
          difficulty_filter="$value"
          shift 2
        else
          errors+=("[${RED}!${RESET}] Invalid difficulty: ${RED}$2${RESET}. Valid values are: ${BLUE}${valid_difficulties[*]}${RESET}")
        fi
        shift 2
      else
        errors+=("[${RED}!${RESET}] Missing difficulty after --difficulty")
        shift
      fi
      ;;
    *)
      echo -e "\n[${GREEN}${@:OPTIND-1:1}${RESET}] Help panel"
      exit 1
      ;;
  esac
done

if (( ${#errors[@]} > 0 )); then
  printf "\n"
  for err in "${errors[@]}"; do
    echo -e "${err}"
  done
  exit 1
fi

if (( flag_u + flag_l + flag_i > 1 )); then
  echo -e "\n[${RED}!${RESET}] Help panel"
  exit 1
fi

if (( flag_l == 0 )) && { [[ -n "$os_filter" ]] || [[ -n "$difficulty_filter" ]]; }; then
  echo -e "\n[${RED}!${RESET}] Help panel"
  exit 1
fi

if [ $flag_u -eq 1 ]; then
  get_all_machines
elif [ $flag_l -eq 1 ]; then
  list_machines "$os_filter" "$difficulty_filter"
elif [ $flag_i -eq 1 ] && [ -n "$machine_name" ];then
  get_machine_info "$machine_name"
fi

exit 0
