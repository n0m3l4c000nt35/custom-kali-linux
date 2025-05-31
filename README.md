<div align=center>
	<h1>Instalación y personalización de Kali Linux</h1>
</div>

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y xorg xinit xserver-xorg virtualbox-guest-x11
mkdir -p $HOME/.config/{bspwm,sxhkd,kitty,polybar}
mkdir $HOME/.config/bspwm/scripts
mkdir $HOME/.config/polybar/scripts
```

## bspwm

```bash
sudo apt install bspwm
cp /usr/share/doc/bspwm/examples/bspwmrc $HOME/.config/bspwm/
chmod u+x $HOME/.config/bspwm/bspwmrc
cp /usr/share/doc/bspwm/examples/sxhkdrc $HOME/.config/sxhkd/
touch $HOME/.config/bspwm/scripts/bspwm_resize
chmod +x $HOME/.config/bspwm/scripts/bspwm_resize
nano $HOME/.config/bspwm/scripts/bspwm_resize
```

```bash
#!/usr/bin/env dash

if bspc query -N -n focused.floating > /dev/null; then
	step=20
else
	step=100
fi

case "$1" in
	west) dir=right; falldir=left; x="-$step"; y=0;;
	east) dir=right; falldir=left; x="$step"; y=0;;
	north) dir=top; falldir=bottom; x=0; y="-$step";;
	south) dir=top; falldir=bottom; x=0; y="$step";;
esac

bspc node -z "$dir" "$x" "$y" || bspc node -z "$falldir" "$x" "$y"
```

```bash
#!/bin/sh

pgrep -x sxhkd > /dev/null || sxhkd &

bspc monitor -d I II III IV V VI VII VIII IX X

bspc config border_width 2
bspc config normal_border_color "#5d5d5d"
bspc config focused_border_color "#1A7A14"
bspc config window_gap 4

bspc config split_ratio 0.52
bspc config borderless_monocle true
bspc config gapless_monocle true

/usr/bin/feh --bg-center $HOME/Pictures/<wallpaper-name>.<extension>

$HOME/.config/polybar/launch.sh &
```

## sxhkdrc

```bash
# terminal emulator
super + Return
	/usr/bin/kitty

# program launcher
super + @space
	dmenu_run

# make sxhkd reload its configuration files:
super + Escape
	pkill -USR1 -x sxhkd

# quit/restart bspwm
super + shift + {q,r}
	bspc {quit,wm -r}

# close and kill
super + {_,shift + }w
	bspc node -{c,k}

# alternate between the tiled and monocle layout
super + m
	bspc desktop -l next

# send the newest marked node to the newest preselected node
super + y
	bspc node newest.marked.local -n newest.!automatic.local

# swap the current node and the biggest window
super + g
	bspc node -s biggest.window

# set the window state
super + {t,shift + t,s,f}
	bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

# set the node flags
super + ctrl + {m,x,y,z}
	bspc node -g {marked,locked,sticky,private}

# focus the node in the given direction
super + {_,shift + }{Left,Down,Up,Right}
	bspc node -{f,s} {west,south,north,east}

# focus the node for the given path jump
super + {p,b,comma,period}
	bspc node -f @{parent,brother,first,second}

# focus the next/previous window in the current desktop
super + {_,shift + }c
	bspc node -f {next,prev}.local.!hidden.window

# focus the next/previous desktop in the current monitor
super + bracket{left,right}
	bspc desktop -f {prev,next}.local

# focus the last node/desktop
super + {grave,Tab}
	bspc {node,desktop} -f last

# focus the older or newer node in the focus history
super + {o,i}
	bspc wm -h off; \
	bspc node {older,newer} -f; \
	bspc wm -h on

# focus or send to the given desktop
super + {_,shift + }{1-9,0}
	bspc {desktop -f,node -d} '^{1-9,10}'

# preselect the direction
super + ctrl + {Left,Down,Up,Right}
	bspc node -p {west,south,north,east}

# preselect the ratio
super + ctrl + {1-9}
	bspc node -o 0.{1-9}

# cancel the preselection for the focused node
super + ctrl + space
	bspc node -p cancel

# cancel the preselection for the focused desktop
super + ctrl + shift + space
	bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

# move a floating window
super + alt + shift + {Left,Down,Up,Right}
	bspc node -v {-20 0,0 20,0 -20,20 0}

# firefox
super + alt + shift + f
  /usr/bin/firefox

# chromium
super + alt + shift + g
	/usr/bin/chromium

# copy target
super + shift + alt + t
  $HOME/.config/polybar/scripts/copy_target.sh
```

## kitty

```bash
sudo apt install kitty
nano $HOME/.config/kitty/kitty.conf
```

```bash
include Box.conf

cursor_shape beam

window_margin_width 2
window_padding_width 5

map ctrl+shift+enter new_window_with_cwd
map ctrl+shift+t new_tab_with_cwd

map ctrl+left neighboring_window left
map ctrl+right neighboring_window right
map ctrl+up neighboring_window up
map ctrl+down neighboring_window down

map ctrl+shift+z toggle_layout stack

map f1 copy_to_buffer a
map f2 paste_from_buffer a
map f3 copy_to_buffer b
map f4 paste_from_buffer b
map f5 copy_to_buffer c
map f6 paste_from_buffer c
map f7 copy_to_buffer d
map f8 paste_from_buffer d
map f9 copy_to_buffer e
map f10 paste_from_buffer e

enable_audio_bell no
```

## Instalar powerlevel10k

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
p10k configure
```

```bash
sudo mkdir /usr/share/zsh-sudo
sudo wget -P /usr/share/zsh-sudo/ https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
```

### zshrc

```bash
export _JAVA_AWT_WM_NONREPARENTING=1

alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

if [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    . /usr/share/zsh-sudo/sudo.plugin.zsh
fi

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi

htb(){
  opt=$1
  case $opt in
    a) sudo openvpn $HOME/academy-regular.ovpn ;;
    m) sudo openvpn $HOME/lab_n0m3l4c000nt35.ovpn ;;
    c) sudo openvpn $HOME/competitive_n0m3l4c000nt35.ovpn ;;
    *) echo "Uso: htb a | m | c"
  esac
}

st(){
  ip_address=$1
  machine_name=$2
  echo "$ip_address" > $HOME/.config/polybar/scripts/target.txt
}

ct(){
  echo "" > $HOME/.config/polybar/scripts/target.txt
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

hth() {
  if [ -z "$1" ]; then
    echo "Usage: hth <ntp-server>"
    return 1
  fi

  echo "[+] Disabling NTP and killing VBoxService..."
  sudo timedatectl set-ntp off >/dev/null 2>&1
  sudo pkill -f VBoxService >/dev/null 2>&1

  echo "[+] Syncing time with: $1"
  sudo ntpdate "$1"
}
```
### .p10k.zsh

```bash
nano $HOME/.p10k.zsh
```

Modificar `<icon>` por un ícono a elección de la web [Nerd Fonts](https://www.nerdfonts.com/cheat-sheet)

```bash
context
command_execution_time
status

typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='<icon>'
typeset -g POWERLEVEL9K_CONTEXT_PREFIX=''

typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=''
```

## batcat y lsd

[Repositorio de batcat](https://github.com/sharkdp/bat)  
[Repositorio de lsd](https://github.com/lsd-rs/lsd)

```bash
wget -P $HOME/Downloads https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
wget -P $HOME/Downloads https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_amd64.deb
sudo dpkg -i $HOME/Downloads/bat_0.25.0_amd64.deb
sudo dpkg -i $HOME/Downloads/lsd_1.1.5_amd64.deb
rm $HOME/Downloads/bat_0.25.0_amd64.deb $HOME/Downloads/lsd_1.1.5_amd64.deb
```

## feh

```bash
sudo apt install feh -y
```

## polybar

[Repositorio de polybar](https://github.com/polybar/polybar)

```bash
sudo apt install polybar -y
echo '$HOME/.config/polybar/launch.sh &' >> $HOME/.config/bspwm/bspwmrc
```

En el archivo `$HOME/.config/polybar/launch.sh` agregar las siguientes líneas

```bash
chmod +x $HOME/.config/polybar/launch.sh
```

```bash
nano $HOME/.config/polybar/launch.sh
```

```bash
#!/bin/bash

killall -q polybar

polybar main -c $HOME/.config/polybar/config.ini
```

```bash
touch $HOME/.config/polybar/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh,copy_target.sh}
chmod +x $HOME/.config/polybar/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh,copy_target.sh}
```

Agregar al archivo `$HOME/.config/polybar/scripts/ethernet_status.sh` el siguiente contenido

```bash
nano $HOME/.config/polybar/scripts/ethernet_status.sh
```

```bash
#!/bin/sh

ETH=$(/usr/sbin/ifconfig ens33 | grep "inet " | awk '{print $2}')

if [ -n "$ETH" ]; then
  echo "%{T2}%{F#2494e7}󰈀%{T-} %{F#fff}$(/usr/sbin/ifconfig ens33 | grep "inet " | awk '{print $2}')"
else
  echo "%{T2}%{F#808080}󰈀%{T-} %{F#fff} Ups!"
fi
```

Agregar al archivo `$HOME/.config/bspwm/scripts/vpn_status.sh` el siguiente contenido

```bash
nano $HOME/.config/bspwm/scripts/vpn_status.sh
```

```bash
#!/bin/sh

IFACE=$(/usr/sbin/ifconfig | grep tun0 | awk '{print $1}' | tr -d ':')

if [ "$IFACE" = "tun0" ]; then
  echo "%{T2}%{F#1bbf3e}󰆧%{T-} %{F#fff}$(/usr/sbin/ifconfig tun0 | grep 'inet ' | awk '{print $2}')"
else
  echo "%{T2}%{F#808080}󰆧%{T-} %{F#fff}Disconnected"
fi
```

Agregar al archivo `$HOME/.config/bspwm/scripts/target_to_hack.sh` el siguiente contenido

```bash
nano $HOME/.config/bspwm/scripts/target_to_hack.sh
```

```bash
#!/bin/bash

ip_address=$(/bin/cat ~/.config/bin/target)

if [ -n "$ip_address" ]; then
  echo "%{T2}%{F#ff0000}󰓾%{T-} %{F#fff}$ip_address"
else
  echo "%{T2}%{F#808080}󰓾%{T-} %{F#fff}No target"
fi
```

Agregar al archivo `$HOME/.config/bspwm/scripts/copy_target.sh` el siguiente contenido

```bash
nano $HOME/.config/bspwm/scripts/copy_target.sh
```

```bash
#!/bin/bash

echo -n "$(cat $HOME/.config/bin/target | awk '{print $1}')" | xclip -sel clip
```

Crear el archivo `$HOME/.config/bin/target`

```bash
mkdir $HOME/.config/bin
touch $HOME/.config/bin/target
```

Agregar al archivo `$HOME/.config/polybar/current.ini` las siguientes líneas

```bash
nano $HOME/.config/polybar/config.ini
```

```bash
[bar/main]
width = 99.5%
height = 40
offset-x = 0.25%
offset-y = 1%
module-margin = 7pt
padding-left = 4
padding-right = 4
background = #aa000000
modules-left = ethernet_status vpn_status
modules-center = workspaces
modules-right = target_to_hack
font-0 = "Hack Nerd Font Mono:style=regular:size=10;1"
font-1 = "Hack Nerd Font Mono:style=regular:size=16;2"
font-2 = "Hack Nerd Font Mono:style=regular:size=18;2"
font-3 = "Hack Nerd Font Mono:style=regular:size=20;4"

[module/ethernet_status]
type = custom/script
exec = $HOME/.config/bspwm/scripts/ethernet_status.sh
interval = 2
format = <label>

[module/vpn_status]
type = custom/script
exec = $HOME/.config/bspwm/scripts/vpn_status.sh
click-left = echo "$(/usr/sbin/ifconfig tun0 | grep "inet " | awk '{print $2}')" | xclip -sel clip
interval = 2
format = <label>

[module/workspaces]
type = internal/xworkspaces
icon-default = 
format = <label-state>
format-font = 3
label-active = 󱓇
label-active-foreground = #39ff14
label-active-padding = 5px
label-active-font = 4
label-occupied = %icon%
label-occupied-foreground = #4439ff14
label-occupied-padding = 5px
label-occupied-font = 2
label-urgent = %icon%
label-urgent-foreground = #e51d0b
label-urgent-padding = 5px
label-empty = %icon%
label-empty-foreground = #6a6a6a
label-empty-padding = 5px
label-empty-font = 2

[module/target_to_hack]
type = custom/script
exec = $HOME/.config/bspwm/scripts/target_to_hack.sh
click-left = echo -n "$(cat $HOME/.config/bin/target)" | xclip -sel clip
interval = 2
format = <label>
```

## Instalar imagemagick

[Repositorio de imagemagick](https://github.com/ImageMagick/ImageMagick)

```bash
sudo apt install imagemagick -y
```

Agregar al archivo `$HOME/.config/bspwm/bspwmrc` la siguiente línea para las aplicaciones JAVA

```bash
nano $HOME/.config/bspwm/bspwmrc
```

```bash
wmname LG3D &
```

# Instalar nvim y nvchad

Chequear si `nvim` está instalado

```bash
which nvim
```

Si `nvim` está instalado, eliminar `nvim` y el binario

```bash
sudo apt remove nvim
sudo rm /usr/bin/nvim
```

[Repositorio de nvchad](https://github.com/NvChad/NvChad)  
[Página oficial de nvchad](https://nvchad.com/docs/quickstart/install/)  
[Repositorio de nvim](https://github.com/neovim/neovim)

```bash
git clone https://github.com/NvChad/starter $HOME/.config/nvim
wget -P $HOME/Downloads https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz
sudo mkdir /opt/nvim
sudo mv $HOME/Downloads/nvim-linux64.tar.gz /opt/nvim
sudo tar -xf /opt/nvim/nvim-linux64.tar.gz -C /opt/nvim
sudo rm /opt/nvim/nvim-linux64.tar.gz
sudo ln -s /opt/nvim/nvim-linux64/bin/nvim /usr/bin/nvim
```

Ejecutar los siguientes comandos para finalizar la instación de `nvim`

```bash
nvim
```

Agregar la siguiente línea al archivo `$HOME/.config/nvim/init.lua` para eliminar el signo dolar/peso `$` en `nvim`

```bash
nvim $HOME/.config/nvim/init.lua
```

```bash
vim.opt.listchars = "tab:»·,trail:·"
```

Agregar la línea `transparency = true` al archivo `$HOME/.config/nvim/lua/chadrc.lua` para agregarle transparencia

```bash
nvim $HOME/.config/nvim/lua/chadrc.lua
```

Debería quedar así

```bash
M.ui = {
»·theme = "onedark",
  transparency = true
»
»·-- hl_override = {
»·-- »Comment = { italic = true },
»·-- »["@comment"] = { italic = true },
»·-- },
}
```

Ejecutar el siguiente comando en nvim `:MasonInstallAll`

```bash
nvim
```

```bash
:MasonInstallAll
```

Ejecutar los siguientes comandos para que el usuario `root` también tenga la misma configuración para `nvim`

```bash
sudo mkdir /root/.config/nvim
sudo cp -r $HOME/.config/nvim/* /root/.config/nvim
sudo su
```

```bash
nvim
```

Ejecutar el siguiente comando como `root` en nvim `:MasonInstallAll`

```bash
nvim
```

```bash
:MasonInstallAll
```

## Instalar fzf

[Repositorio de fzf](https://github.com/junegunn/fzf)
Instalar `fzf` tanto como usuario no privilegiado como `root`

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install
```

## Instalar i3lock

```bash
sudo apt install i3lock -y
sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy
sudo make -C /opt/i3lock-fancy install
```

Agregar las siguientes líneas al archivo `$HOME/.config/sxhkd/sxhkdrc`

```bash
nano $HOME/.config/sxhkd/sxhkdrc
```

```bash
# i3lock-fancy
super + shift + x
  /usr/bin/i3lock-fancy
```

## Instalar locate

```bash
sudo apt install locate && sudo updatedb
```

## Otras configuraciones

Para que Firefox resuelva los dominios de `hack the box` ingresar en la barra de navegación `about:config`, ingresar `browser.fixup.domainsuffixwhitelist.htb` y ponerlo en `true`

Modificar el rate y delay del teclado

```bash
nano $HOME/.xprofile
```

```
xset r rate 250 25
```

Configurar Git

```bash
git config --global user.name "<username>"
git config --global user.email "<email>"
git config --global core.editor "code --wait"
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm "commit -m"
```

Instalar **NVM**

[Repositorio de Github](https://github.com/nvm-sh/nvm)

Instalar **Node**

[Descargar Node.js](https://nodejs.org/es/download)

Instalar **Docker**

[Descargar Docker](https://docs.docker.com/engine/install/ubuntu/)

Instalar Python2.7

```bash
sudo nano /etc/apt/sources.list
# Agregar la siguiente línea al archivo /etc/apt/sources.list
deb http://archive.debian.org/debian/ stretch contrib main non-free
sudo apt-get update
sudo apt-get install python2.7
```
