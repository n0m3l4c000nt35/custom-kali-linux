#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
GRAY="\e[90m"
RESET='\033[0m'

API_URL="https://labs.hackthebox.com/api/v4"
APP_TOKEN=$(cat $HOME/.config/htb/htbash.conf)
HTB_MACHINES_DIR="$HOME/htb/machines"
VPN_CONFIG="$HOME/.config/htb/vpn"

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

while getopts "li:" opt 2>/dev/null; do
  case $opt in
    l) echo "Listing machines";;
    i) get_machine_info "$OPTARG";;
    \?) echo -e "\n[${@:OPTIND-1:1}] ${GREEN}Help panel${RESET}";;
  esac
done

exit 0
