#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\e[33m'
GRAY='\e[90m'
BLUE='\e[34m'
RESET='\033[0m'

API_URL="https://labs.hackthebox.com/api/v4"
APP_TOKEN=$(cat $HOME/.config/htb/htbash.conf)
HTB_MACHINES_DIR="$HOME/htb/machines"
MACHINES_JSON="$HOME/.config/htb/machines/machines.json"
VPN_CONFIG="$HOME/.config/htb/vpn"

show_help() {
  echo -e "\n${GREEN} 󰆧${RESET} htbash Help ${GREEN}󰆧 ${RESET}\n"
  echo -e "${YELLOW}Description:${RESET} Manage Hack The Box machines via API.\n"
  echo -e "${YELLOW}Usage:${RESET} htbash [OPTIONS]\n"
  echo -e "${YELLOW}Options:${RESET}"
  echo -e "  ${BLUE}-u${RESET}\t\t\tUpdate machine list from HTB API"
  echo -e "  ${BLUE}-l${RESET}\t\t\tList machines (filter with --os, --difficulty, or --free)"
  echo -e "  ${BLUE}--os${RESET}\t<${GREEN}linux${RESET}|${GREEN}windows${RESET}> Filter by OS"
  echo -e "  ${BLUE}--difficulty${RESET} <${GREEN}easy${RESET}|${GREEN}medium${RESET}|${GREEN}hard${RESET}|${GREEN}insane${RESET}> Filter by difficulty"
  echo -e "  ${BLUE}--free${RESET}\t\tFilter to show only free machines"
  echo -e "  ${BLUE}--owned${RESET}\t<${GREEN}y${RESET}|${GREEN}n${RESET}>\tFilter by owned status (y=owned, n=not owned)"
  echo -e "  ${BLUE}-i${RESET} <machine>\t\tShow machine details"
  echo -e "  ${BLUE}-p${RESET} <machine>\t\tSetup workspace and VPN for machine"
  echo -e "  ${BLUE}--vpn${RESET}\t<${GREEN}comp${RESET}|${GREEN}lab${RESET}|${GREEN}pro${RESET}> Select VPN configuration (use with -p)\n"
  echo -e "${YELLOW}Examples:${RESET}"
  echo -e "  ${BLUE}htbash -u${RESET}\t\t# Update machine list"
  echo -e "  ${BLUE}htbash -l --os linux${RESET}\t# List Linux machines"
  echo -e "  ${BLUE}htbash -l --free${RESET}\t\t# List only free machines"
  echo -e "  ${BLUE}htbash -l --owned y${RESET}\t\t# List only owned machines"
  echo -e "  ${BLUE}htbash -i Lame${RESET}\t\t# Show Lame machine info"
  echo -e "  ${BLUE}htbash -p Lame${RESET}\t\t# Setup workspace for Lame"
  echo -e "  ${BLUE}htbash -p Lame --vpn comp${RESET}\t# Setup workspace with competitive VPN\n"
  echo -e "${YELLOW}Notes:${RESET}"
  echo -e "  - Requires HTB API token in ${BLUE}\$HOME/.config/htb/htbash.conf${RESET}"
  echo -e "  - Flags ${BLUE}-u${RESET}, ${BLUE}-l${RESET}, ${BLUE}-i${RESET}, ${BLUE}-p${RESET} are exclusive"
  echo -e "  - Use ${BLUE}--os${RESET}, ${BLUE}--difficulty${RESET}, or ${BLUE}--owned${RESET} ${BLUE}--free${RESET} only with ${BLUE}-l${RESET}"
  echo -e "  - Use ${BLUE}--vpn${RESET} only with ${BLUE}-p${RESET}\n"
  echo -e "${GREEN}=== Happy Hacking! ===${RESET}"
}

fetch_active_machines() {
  local base_url="$API_URL/machine/paginated?retired=0&page="
  local all_data="[]"
  local last_page
  last_page=$(curl -s "${base_url}1" -H "Authorization: Bearer $APP_TOKEN" | jq -r '.meta.last_page')

  for (( page=1; page<=last_page; page++ )); do
      local page_data
      page_data=$(curl -s "${base_url}${page}" -H "Authorization: Bearer $APP_TOKEN" | jq '.data | map(.status = "active")')
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
      page_data=$(curl -s "${base_url}${page}" -H "Authorization: Bearer $APP_TOKEN" | jq '.data | map(.status = "retired")')
      all_data=$(jq -s 'add' <(echo "$all_data") <(echo "$page_data"))
  done

  echo "$all_data"
}

update_machines(){
  local active_machines retired_machines all_machines active_count retired_count total_count

  show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    tput civis
    echo
    while kill -0 $pid 2>/dev/null; do
      for char in $(echo "$spinstr" | grep -o .); do
        printf "\r[${BLUE}%s${RESET}] Updating machines..." "$char"
        sleep $delay
        kill -0 $pid 2>/dev/null || break
      done
    done
    printf "\r\033[K"
    tput cnorm
  }

  {
    active_machines=$(fetch_active_machines)
    retired_machines=$(fetch_retired_machines)
    all_machines=$(jq -s 'add' <(echo "$active_machines") <(echo "$retired_machines"))
    echo "$all_machines" > "$MACHINES_JSON"
  } &

  show_spinner $!

  active_count=$(jq '[.[] | select(.status == "active")] | length' "$MACHINES_JSON")
  retired_count=$(jq '[.[] | select(.status == "retired")] | length' "$MACHINES_JSON")
  total_count=$(jq 'length' "$MACHINES_JSON")

  echo -e "[${GREEN}Machines updated${RESET}]"
  echo
  echo -e "[${YELLOW}Total active machines${RESET}] $active_count"
  echo -e "[${YELLOW}Total retired machines${RESET}] $retired_count"
  echo -e "[${YELLOW}Total machines saved${RESET}] $total_count"
  echo
  echo -e "[${YELLOW}DATA SAVED TO${RESET}] $MACHINES_JSON"
}

list_machines(){
  local os="$1"
  local difficulty="$2"
  local free="$3"
  local owned="$4"
  echo
  headers=("Name" "OS" "Free" "Difficulty" "Owned")
  mapfile -t rows < <(jq -r --arg os "$os" --arg difficulty "$difficulty" --arg free "$free" --arg owned "$owned" '.[] | select(($os == "" or ($os | ascii_downcase) == (.os | ascii_downcase)) and ($difficulty == "" or ($difficulty | ascii_downcase) == (.difficultyText | ascii_downcase)) and ($free == "0" or .free == true) and ($owned == "" or ($owned == "y" and .authUserInUserOwns == true) or ($owned == "n" and .authUserInUserOwns == false))) | [.name, .os, (if .free then "True" else "False" end), .difficultyText, (if .authUserInUserOwns then "Y" else "N" end)] | @tsv' "$MACHINES_JSON")
  total_machines=${#rows[@]}
  col_widths=()
  for i in "${!headers[@]}"; do
    col_widths[i]=${#headers[i]}
  done
  for row in "${rows[@]}"; do
  IFS=$'\t' read -r col1 col2 col3 col4 col5 <<< "$row"
    [[ ${#col1} -gt ${col_widths[0]} ]] && col_widths[0]=${#col1}
    [[ ${#col2} -gt ${col_widths[1]} ]] && col_widths[1]=${#col2}
    [[ ${#col3} -gt ${col_widths[2]} ]] && col_widths[2]=${#col3}
    [[ ${#col4} -gt ${col_widths[3]} ]] && col_widths[3]=${#col4}
    [[ ${#col5} -gt ${col_widths[4]} ]] && col_widths[4]=${#col5}
  done
  center_text(){
    local text="$1"
    local width="$2"
    local pad=$(( (width - ${#text}) / 2 ))
    printf "%*s%s%*s" $pad "" "$text" $((width - pad - ${#text})) ""
  }
  center_text_colored(){
    local text="$1"
    local width="$2"
    local color="$3"
    local pad=$(( (width - ${#text}) / 2 ))
    printf "%*s${color}%s${RESET}%*s" $pad "" "$text" $((width - pad - ${#text})) ""
  }
  separator="+"
  for w in "${col_widths[@]}"; do
    separator+=$(printf '%0.s-' $(seq 1 $((w + 2))))
    separator+="+"
  done
  title="Hack The Box Machines"
  
  total_width=${#separator}
  available_width=$((total_width - 4))
  title_length=${#title}
  
  left_padding=$(( (available_width - title_length) / 2 ))
  right_padding=$(( available_width - title_length - left_padding ))
  
  echo "$separator"
  printf "| %*s${GREEN}%s${RESET}%*s |\n" $left_padding "" "$title" $right_padding ""
  echo "$separator"
  printf "|"
  for i in "${!headers[@]}"; do
    printf " %s |" "$(center_text "${headers[i]}" "${col_widths[i]}")"
  done
  echo
  echo "$separator"
  for row in "${rows[@]}"; do
  IFS=$'\t' read -r col1 col2 col3 col4 col5 <<< "$row"
    if [[ "$col5" == "Y" ]]; then
      colored_col5="$(center_text_colored "$col5" "${col_widths[4]}" "$GREEN")"
    elif [[ "$col5" == "N" ]]; then
      colored_col5="$(center_text_colored "$col5" "${col_widths[4]}" "$GRAY")"
    else
      colored_col5="$(center_text "$col5" "${col_widths[4]}")"
    fi
  printf "| %-*s | %-*s | %-*s | %-*s | %s |\n" \
    "${col_widths[0]}" "$col1" \
    "${col_widths[1]}" "$col2" \
    "${col_widths[2]}" "$col3" \
    "${col_widths[3]}" "$col4" \
    "$colored_col5"
  done
  echo "$separator"
  footer_text="$total_machines"
  footer_length=${#footer_text}
  footer_left_padding=$(( (available_width - footer_length) / 2 ))
  footer_right_padding=$(( available_width - footer_length - footer_left_padding ))
  printf "| %*s${GREEN}%s${RESET}%*s |\n" $footer_left_padding "" "$footer_text" $footer_right_padding ""
  echo "$separator"
}

get_machine_info(){
  local machine machine_name
  machine_name=$1
  machine=$(curl -s "$API_URL/machine/profile/$machine_name" -H "Authorization: Bearer $APP_TOKEN" | jq '.info')

  echo "$machine"
}

print_machine(){
  local machine_name machine
  machine_name=$1
  machine=$(get_machine_info $machine_name)

  if [[ "$machine" == "null" ]]; then
    echo
    echo -e "[${RED}!${RESET}] Machine ${RED}$machine_name${RESET} not found."
    exit 1
  fi

  echo
  echo -e "${GREEN}Machine name${RESET}:" $(echo "$machine" | jq -r '.name')
  echo -e "${GREEN}OS${RESET}:" $(echo "$machine" | jq -r '.os')
  echo -e "${GREEN}Status${RESET}:" $(echo "$machine" | jq -r 'if .active then "Active" else "Retired" end')
  echo -e "${GREEN}Release date${RESET}:" $(echo "$machine" | jq -r '.release | sub("\\.[0-9]{3,6}Z$"; "Z") | fromdate | strftime("%d-%m-%Y")')
  echo -e "${GREEN}Points${RESET}:" $(echo "$machine" | jq -r '.points')
  echo -e "${GREEN}User Owns${RESET}:" $(echo "$machine" | jq -r '.user_owns_count')
  echo -e "${GREEN}Root Owns${RESET}:" $(echo "$machine" | jq -r '.root_owns_count')
  echo -e "${GREEN}Stars${RESET}:" $(echo "$machine" | jq -r '.stars')
  echo -e "${GREEN}Avatar${RESET}: https://www.hackthebox.com"$(echo "$machine" | jq -r '.avatar')
  echo -e "${GREEN}Difficulty${RESET}:" $(echo "$machine" | jq -r '.difficultyText')
  if [[ $(echo "$machine" | jq -r '.synopsis != null') == "true" ]]; then
    echo -e "${GREEN}Synopsis${RESET}:" $(echo "$machine" | jq -r '.synopsis')
  fi
}

create_writeup() {
  local machine_dir machine_name machine_data name os release status user_owns root_owns stars avatar difficulty synopsis

  machine_dir="$1"
  machine_name="$2"

  machine_data=$(get_machine_info $machine_name)

  name=$(echo "${machine_data}" | jq -r '.name')
  os=$(echo "${machine_data}" | jq -r '.os')
  release=$(echo "${machine_data}" | jq -r '.release | sub("\\.[0-9]{3,6}Z$"; "Z") | fromdate | strftime("%d-%m-%Y")')
  status=$(echo "${machine_data}" | jq -r 'if .active then "Active" else "Retired" end')
  user_owns=$(echo "${machine_data}" | jq -r '.user_owns_count')
  root_owns=$(echo "${machine_data}" | jq -r '.root_owns_count')
  star=$(echo "${machine_data}" | jq -r '.stars')
  avatar=$(echo "${machine_data}" | jq -r '.avatar')
  difficulty=$(echo "${machine_data}" | jq -r '.difficultyText')
  synopsis=$(echo "${machine_data}" | jq -r '.synopsis')
  synopsis_line=""
  if [[ "$synopsis" != "null" ]]; then
    synopsis_line="- **Synopsis**: ${synopsis}"
  fi

  cat << EOF > "${machine_dir}/writeup.md"
# Hack The Box - ${name} Writeup

<div align="center">
  <img src="https://www.hackthebox.com${avatar}" alt="${name}" width="250" height="250">
</div>

## Machine Information
- **Name**: ${name}
- **OS**: ${os}
- **Difficulty**: ${difficulty}
- **Status**: ${status}
- **Release**: ${release}
- **Stars**: ${star}
- **User Owns**: ${user_owns}
- **Root Owns**: ${root_owns}
${synopsis_line}

## Reconnaissance

## Enumeration

## Exploitation

## Post-Exploitation

## Autopwn
\`\`\`python
#!/usr/bin/env python3

\`\`\`
EOF
}

play_machine(){
  local machine_name="$1"
  local vpn_type="$2"
  local machine_data machine_dir current_tab_id current_tab_title open_tab_titles

  case "$vpn_type" in
    "comp")
      vpn_file="${VPN_CONFIG}/competitive_$HTB_USER.ovpn"
      ;;
    "lab")
      vpn_file="${VPN_CONFIG}/lab_$HTB_USER.ovpn"
      ;;
    *)
      vpn_file="${VPN_CONFIG}/lab_$HTB_USER.ovpn"
      ;;
  esac

  echo
  machine_data=$(jq --arg name "$machine_name" '.[] | select((.name | ascii_downcase) == ($name | ascii_downcase ))' "$MACHINES_JSON")
  machine_dir="$HTB_MACHINES_DIR/$machine_name"

  current_tab_id=$(kitten @ ls | jq -r '.[] | .tabs[] | select(.is_active == true) | .id' 2>/dev/null)
  current_tab_title=$(kitten @ ls | jq -r '.[] | .tabs[] | select(.is_active == true) | .title' 2>/dev/null)

  if [[ -d "$machine_dir" ]]; then
    if ip a | grep -q "tun0"; then
      pkill -f "openvpn.*${VPN_CONFIG}" 2>/dev/null
    fi
  fi

  open_tab_titles=($(kitten @ ls | jq -r '.[] | .tabs[] | .title' 2>/dev/null))

  local tab_titles=("vpn" "writeup" "recon" "exploits" "loot" "scripts" "$machine_name")

  for title in "${open_tab_titles[@]}"; do
    if [[ " ${fixed_tab_titles[*]} " =~ " ${title} " || "${title,,}" != "${machine_name,,}" ]]; then
      kitten @ close-tab --match "title:$title and not id:$current_tab_id" 2>/dev/null
    fi
  done

  if [[ ! -d "${machine_dir}" ]]; then
    mkdir -p "${machine_dir}/recon" "${machine_dir}/exploits" "${machine_dir}/loot" "${machine_dir}/scripts"
    create_writeup "${machine_dir}" "${machine_name}"
    touch "${machine_dir}/users.txt" "${machine_dir}/passwords.txt"
  fi
 
  kitten @ launch --type=tab --no-response --tab-title "vpn" bash -c "sudo /usr/sbin/openvpn ${vpn_file}"
  kitten @ launch --type=tab --no-response --tab-title "${machine_name}" --cwd "${machine_dir}"
  kitten @ launch --type=tab --no-response --tab-title "writeup" --cwd "${machine_dir}" bash -c "nvim writeup.md -c MarkdownPreview"
  kitten @ launch --type=tab --no-response --tab-title "recon" --cwd "${machine_dir}/recon"
  kitten @ launch --type=tab --no-response --tab-title "exploits" --cwd "${machine_dir}/exploits"
  kitten @ launch --type=tab --no-response --tab-title "loot" --cwd "${machine_dir}/loot"
  kitten @ launch --type=tab --no-response --tab-title "scripts" --cwd "${machine_dir}/scripts"
  kitten @ focus-tab --match "title:${machine_name}" 2>/dev/null

  local created_tab_titles=("${fixed_tab_titles[@]}" "$machine_name")
  if [[ ! " ${created_tab_titles[*]} " =~ " ${current_tab_title} " ]]; then
    kitten @ close-tab --match "id:${current_tab_id}" 2>/dev/null
  fi
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

flag_u=0
flag_l=0
flag_i=0
flag_p=0
flag_free=0

machine_name=""
os_filter=""
difficulty_filter=""
vpn_type=""
owned_filter=""

valid_os=("linux" "windows")
valid_difficulties=("easy" "medium" "hard" "insane")
valid_vpn_types=("comp" "lab" "pro")
valid_owned=("y" "n")

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
        echo -e "\n[${RED}!${RESET}] Missing machine name after ${GREEN}-i${RESET}"
        show_help
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
        errors+=("[${RED}!${RESET}] Missing OS after ${GREEN}--os${RESET}")
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
          shift 2
        fi
      else
        errors+=("[${RED}!${RESET}] Missing difficulty after ${GREEN}--difficulty${RESET}")
        shift
      fi
      ;;
    --free)
        flag_free=1
        shift
      ;;
    --owned)
      if [[ -n "$2" && "$2" != -* ]]; then
        value=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        if is_valid_value "$value" "${valid_owned[@]}"; then
          owned_filter="$value"
          shift 2
        else
          errors+=("[${RED}!${RESET}] Invalid owned value: ${RED}$2${RESET}. Valid values are: ${BLUE}${valid_owned[*]}${RESET}")
          shift 2
        fi
      else
        errors+=("[${RED}!${RESET}] Missing owned value after ${GREEN}--owned${RESET}")
        shift
      fi
      ;;
    -p)
      if [[ -n "$2" && "$2" != -* ]]; then
        flag_p=1
        machine_name="$2"
        shift 2
      else
        echo -e "\n[${RED}!${RESET}] Missing machine name after ${GREEN}-p${RESET}"
        show_help
        exit 1
      fi
      ;;
    --vpn)
      if [[ -n "$2" && "$2" != -* ]]; then
        value=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        if is_valid_value "$value" "${valid_vpn_types[@]}"; then
          vpn_type="$value"
          shift 2
        else
          errors+=("[${RED}!${RESET}] Invalid VPN type: ${RED}$2${RESET}. Valid values are: ${BLUE}${valid_vpn_types[*]}${RESET}")
          shift 2
        fi
      else
        errors+=("[${RED}!${RESET}] Missing VPN type after ${GREEN}--vpn${RESET}")
        shift
      fi
      ;;
    *)
      echo
      echo -e "[${RED}Say what?${RESET}]"
      exit 1
      ;;
  esac
done

if (( flag_u + flag_l + flag_i + flag_p > 1 )); then
  show_help
  exit 1
fi

if (( flag_l == 0 )) && { [[ -n "$os_filter" ]] || [[ -n "$difficulty_filter" ]] || [[ "$flag_free" -eq 1 ]] || [[ -n "$owned_filter" ]]; }; then
  if [[ -n "$os_filter" ]] && [[ -n "$difficulty_filter" ]] && [[ -n "$free_filter" ]] && [[ -n "$owned_filter" ]]; then
    echo
    echo -e "[${RED}!${RESET}] The flags ${BLUE}--os${RESET}, ${BLUE}--difficulty${RESET} and ${BLUE}--free${RESET} can only be used with the ${BLUE}-l${RESET} flag to list machines."
  elif [[ -n "$os_filter" ]]; then
    echo
    echo -e "[${RED}!${RESET}] The flag ${BLUE}--os${RESET} can only be used with the ${BLUE}-l${RESET} flag to list machines."
  elif [[ -n "$difficulty_filter" ]]; then
    echo
    echo -e "[${RED}!${RESET}] The flag ${BLUE}--difficulty${RESET} can only be used with the ${BLUE}-l${RESET} flag to list machines."
  elif [[ "$flag_free" -eq 1 ]]; then
    echo
    echo -e "[${RED}!${RESET}] The flag ${BLUE}--free${RESET} can only be used with the ${BLUE}-l${RESET} flag to list machines."
  elif [[ "$owned_filter" -eq 1 ]]; then
    echo
    echo -e "[${RED}!${RESET}] The flag ${BLUE}--owned${RESET} can only be used with the ${BLUE}-l${RESET} flag to list machines."
  fi
  show_help
  exit 1
fi

if (( flag_p == 0 )) && [[ -n "$vpn_type" ]]; then
  echo
  echo -e "[${RED}!${RESET}] The flag ${BLUE}--vpn${RESET} can only be used with the ${BLUE}-p${RESET} flag to play machines."
  show_help
  exit 1
fi

if (( ${#errors[@]} > 0 )); then
  printf "\n"
  for err in "${errors[@]}"; do
    echo -e "${err}"
  done
  show_help
  exit 1
fi

if [ $flag_u -eq 1 ]; then
  update_machines
elif [ $flag_l -eq 1 ]; then
  list_machines "$os_filter" "$difficulty_filter" "$flag_free" "$owned_filter"
elif [ $flag_i -eq 1 ] && [ -n "$machine_name" ];then
  print_machine "$machine_name"
elif [ $flag_p -eq 1 ] && [ -n "$machine_name" ]; then
  if jq -e --arg name "$machine_name" '.[] | select(($name | ascii_downcase) == (.name | ascii_downcase))' "$MACHINES_JSON" > /dev/null; then
    if [[ -z "$vpn_type" ]]; then
      vpn_type="comp"
    fi
    play_machine "$machine_name"
  else
    echo -e "\n[${RED}!${RESET}] Machine ${RED}$machine_name${RESET} not exists."
    exit 1
  fi
fi

exit 0
