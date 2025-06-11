
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi

if [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    . /usr/share/zsh-sudo/sudo.plugin.zsh
fi

export HTB_USER="htbu53r"
export _JAVA_AWT_WM_NONREPARENTING=1

alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

# Se conecta a la VPN de Hack The Box dependiendo si te conectás a la academia, a los laboratorios o estás haciendo las máquinas de la season. En este caso los archivos se guardan en el $HOME.
htb(){
    opt=$1
    case $opt in
      a) sudo openvpn $HOME/academyvpnfile ;;
      m) sudo openvpn $HOME/labsvpnfile ;;
      c) sudo openvpn $HOME/competitivevpnfile ;;
      *) echo "Uso: htb a | m | c"
    esac
}

# Muestra en la polybar la IP de la máquina que estás haciendo
st(){
    echo "$1" > $HOME/.config/polybar/scripts/target.txt
}

# Elimina la IP de la máquina que estabas haciendo de la Polybar
ct(){
    echo "" > $HOME/.config/polybar/scripts/target.txt
}

# Extrae los números de puertos del output guardado en un archivo en formato grepeable de un escaneo con nmap
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

# Si le pasa una IP sincroniza la hora con la del servidor para trabajar en entornos que así lo requieren, si no se le pasa una IP sincroniza la hora con la local. Está creado específicamente para este entorno.
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

# Oculta una flag por si la querés usar en un writeup
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
