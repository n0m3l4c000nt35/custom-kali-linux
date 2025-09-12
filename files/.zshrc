HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history
setopt append_history
setopt inc_append_history

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi

export HTB_USER="<hacktheboxusername>"
export _JAVA_AWT_WM_NONREPARENTING=1

alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# ZSH Sudo plugin
if [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    . /usr/share/zsh-sudo/sudo.plugin.zsh
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Para Ctrl+T (archivos)
export FZF_CTRL_T_OPTS="--preview 'bat --style=full --color=always {}'"
# Para Alt+C (directorios)
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

RED='\033[0;31m'
RESET='\033[0m'

htb(){
    opt=$1
    case $opt in
      a) sudo openvpn $HOME/.config/htb/vpn/academy-regular.ovpn ;;
      m) sudo openvpn $HOME/.config/htb/vpn/lab_n0m3l4c000nt35.ovpn ;;
      c) sudo openvpn $HOME/.config/htb/vpn/competitive_n0m3l4c000nt35.ovpn ;;
      *)
        echo
        echo "Usage: htb <a|m|c>"
    esac
}

target() {
    local target_file="$HOME/.config/polybar/scripts/target.txt"
    
    if [[ $# -eq 0 ]]; then
      echo "" > "$target_file"
    elif [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      echo "$1" > "$target_file"
    else
      echo
      echo "[${RED}!${RESET}] Invalid IP format"
    fi
}

ep(){
    ports="$(/usr/bin/cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(/usr/bin/cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
    echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
    echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
    echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
    echo $ports | tr -d '\n' | xclip -sel clip
    echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
    cat extractPorts.tmp; rm extractPorts.tmp
}

hth(){
    if [ -z "$1" ]; then
      echo "[+] No NTP server provided. Syncing with host time (VBox)..."
      sudo timedatectl set-ntp off > /dev/null 2>&1
      sudo VBoxService > /dev/null 2>&1
    else
      echo "[+] Disabling NTP and killing VBoxService..."
      sudo timedatectl set-ntp off > /dev/null 2>&1
      sudo pkill -f VBoxService > /dev/null 2>&1
      echo "[+] Syncing time with: $1"
      sudo ntpdate "$1"
    fi
}

hflag() {
  if [[ $# -eq 0 ]]; then
      echo "Usage: hflag <flag>"
      echo "Example: hflag c2244cc01f0d0ad967f32fb15a5ebeca"
      exit 1
  fi
  
  local flag="$1"
  local flag_length=${#flag}
  
  local show_start=0
  local show_end=0
  
  if [[ $flag_length -le 8 ]]; then
      show_start=1
      show_end=1
  elif [[ $flag_length -le 16 ]]; then
      show_start=2
      show_end=2
  elif [[ $flag_length -le 24 ]]; then
      show_start=3
      show_end=3
  else
      show_start=4
      show_end=4
  fi
  
  if [[ $((show_start + show_end)) -ge $flag_length ]]; then
      show_start=1
      show_end=1
  fi
  
  local start_part="${flag:0:$show_start}"
  local end_part="${flag: -$show_end}"
  local hidden_length=$((flag_length - show_start - show_end))
  
  local asterisks=""
  for ((i=0; i<hidden_length; i++)); do
      asterisks+="*"
  done
  
  echo "${start_part}${asterisks}${end_part}"
}
