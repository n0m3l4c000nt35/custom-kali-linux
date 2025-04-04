# Personalización de Linux

![cl](https://github.com/user-attachments/assets/fdfa3d8a-de11-4989-bce4-9cde8dc09bd9)

- [Instalar dependencias](#Instalar-dependencias)
- [Instalar bspwm](#Instalar-bspwm)
- [Instalar sxhkd](#Instalar-sxhkd)
- [Configuración de bspwm y sxhkd](#Configuracion-de-bspwm-y-sxhkd)
- [Instalar kitty](#Instalar-kitty)
- [Instalar zsh](#Instalar-zsh)
- [Instalar fuentes](#Instalar-fuentes)
- [Instalar powerlevel10k](#Instalar-powerlevel10k)
- [Instalar picom](#Instalar-picom)
- [Instalar batcat y lsd](#Instalar-batcat-y-lsd)
- [Instalar feh](#Instalar-feh)
- [Instalar polybar](#Instalar-polybar)
- [Instalar imagemagick](#Instalar-imagemagick)
- [Instalar nvim y nvchad](#Instalar-nvim-y-nvchad)
- [Instalar fzf](#Instalar-fzf)
- [Instalar i3lock](#Instalar-i3lock)
- [Instalar locate](#Instalar-locate)
- [Otras configuraciones](#Otras-configuraciones)

## Instalar dependencias

```bash
sudo apt install git make build-essential p7zip-full libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev -y
```

## Instalar bspwm

[Repositorio de bspwm](https://github.com/baskerville/bspwm)

```bash
git clone https://github.com/baskerville/bspwm.git $HOME/Downloads/bspwm
sudo make -C $HOME/Downloads/bspwm
sudo make -C $HOME/Downloads/bspwm install
```

## Instalar sxhkd

[Repositorio de sxhkd](https://github.com/baskerville/sxhkd)

```bash
git clone https://github.com/baskerville/sxhkd.git $HOME/Downloads/sxhkd
sudo make -C $HOME/Downloads/sxhkd
sudo make -C $HOME/Downloads/sxhkd install
```

## Configuracion de `bspwm` y `sxhkd`

```bash
mkdir $HOME/.config/{bspwm,sxhkd}
cp $HOME/Downloads/bspwm/examples/bspwmrc $HOME/.config/bspwm/
chmod u+x $HOME/.config/bspwm/bspwmrc
cp $HOME/Downloads/bspwm/examples/sxhkdrc $HOME/.config/sxhkd/
rm -rf $HOME/Downloads/{bspwm,sxhkd}
```

Modificar las siguientes líneas del archivo `$HOME/.config/sxhkd/sxhkdrc`

```bash
nano $HOME/.config/sxhkd/sxhkdrc
```

```bash
# quit/restart bspwm
super + shift + {q,r}
  bspc {quit,wm -r}

# focus the node in the given direction
super + {_,shift + }{Left,Down,Up,Right}
  bspc node -{f,s} {west,south,north,east}

# preselect the direction
super + ctrl + alt + {Left,Down,Up,Right}
  bspc node -p {west,south,north,east}

# move a floating window
super + alt + shift + {Left,Down,Up,Right}
  bspc node -v {-20 0,0 20,0 -20,20 0}

# custom resize
super + alt + {Left,Down,Up,Right}
  $HOME/.config/bspwm/scripts/bspwm_resize {west,south,north,east}
```

Eliminar las siguientes líneas del archivo `~/.config/sxhkd/sxhkdrc`

```bash
nano ~/.config/sxhkd/sxhkdrc
```

```bash
# expand a window by moving one of its side outward
super + alt + {h,j,k,l}
  bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

# contract a window by moving one of its side inward
super + alt + shift + {h,j,k,l}
  bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}
```

Crear el script `$HOME/.config/bspwm/scripts/bspwm_resize`

```bash
mkdir $HOME/.config/bspwm/scripts
touch $HOME/.config/bspwm/scripts/bspwm_resize
chmod +x $HOME/.config/bspwm/scripts/bspwm_resize
```

Agregarle el siguiente contenido al archivo `$HOME/.config/bspwm/scripts/bspwm_resize`

```bash
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

Agregar la siguiente línea al archivo `$HOME/.config/bspwm/bspwmrc`

Para poder copiar de manera bidireccional entre la máquina host y la máquina virtual, agregar la siguiente línea al archivo `$HOME/.config/bspwm/bspwmrc`

```bash
nano $HOME/.config/bspwm/bspwmrc
```

```bash
#!/bin/sh

pgrep -x sxhkd > /dev/null || sxhkd &

bspc monitor -d I II III IV V VI VII VIII IX X

bspc config borderless_monocle   true
bspc config gapless_monocle      true

bspc config split_ratio 0.5

bspc config window_gap 4
bspc config border_width 1
bspc config normal_border_color "#5d5d5d"
bspc config focused_border_color "#1A7A14"

vmware-user-suid-wrapper &
```

Eliminar las siguientes líneas del archivo `$HOME/.config/bspwm/bspwmrc`

```bash
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a Chromium desktop='^2'
bspc rule -a mplayer2 state=floating
bspc rule -a Kupfer.py focus=on
bspc rule -a Screenkey manage=off
```

Agregar lo siguiente al archivo `$HOME/.config/sxhkd/sxhkdrc` para abrir `firefox` y `chromium`

```bash
nano $HOME/.config/sxhkd/sxhkdrc
```

```bash
# open firefox
super + shift + f
  /usr/bin/firefox

# open chromium
super + shift + g
    /usr/bin/chromium 2>/dev/null & disown

# copy target
super + shift + alt + t
  $HOME/.config/bspwm/scripts/copy_target.sh
```

## Instalar kitty

[Repositorio de kitty](https://github.com/kovidgoyal/kitty)

```bash
sudo mkdir /opt/kitty
wget -O- https://github.com/kovidgoyal/kitty/releases/download/v0.41.1/kitty-0.41.1-x86_64.txz | sudo tar -xJ -C /opt/kitty
sudo ln -s /opt/kitty/bin/kitty /usr/bin/kitty
sudo ln -s /opt/kitty/bin/kitten /usr/bin/kitten
```

Modificar las siguientes líneas al archivo `$HOME/.config/sxhkd/sxhkdrc`

```bash
nano $HOME/.config/sxhkd/sxhkdrc
```

```bash
# terminal emulator
super + Return
	/usr/bin/kitty
```

Crear el archivo `$HOME/.config/kitty/kitty.conf` y agregarle el siguiente contenido

```bash
mkdir -p $HOME/.config/kitty
nano $HOME/.config/kitty/kitty.conf
```

```bash
font_family JetBrainsMono
cursor_shape beam

active_border_color #39ff14
inactive_border_color #5d5d5d

window_margin_width 2
window_border_width 1
window_padding_width 5

map ctrl+left neighboring_window left
map ctrl+right neighboring_window right
map ctrl+up neighboring_window up
map ctrl+down neighboring_window down

map ctrl+shift+enter new_window_with_cwd
map ctrl+shift+t new_tab_with_cwd

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

map ctrl+shift+z toggle_layout stack

tab_bar_style powerline

inactive_tab_background #e06c75
active_tab_background #98c379
inactive_tab_foreground #000000
tab_bar_margin_color #000

background_opacity 0.80
enable_audio_bell no
```

```bash
sudo mkdir -p /root/.config/kitty
sudo ln -s $HOME/.config/kitty/kitty.conf /root/.config/kitty/kitty.conf
```

## Instalar zsh

Reemplazar `<user>` por el usuario no privilegiado.

[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

```bash
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting -y
sudo usermod --shell /usr/bin/zsh $USER
sudo usermod --shell /usr/bin/zsh root
```

Agregar la siguiente línea al archivo `$HOME/.config/kitty/kitty.conf`

```bash
nano $HOME/.config/kitty/kitty.conf
```

```bash
shell zsh
```

## Instalar fuentes

[MesloLGS NF](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#manual-font-installation)

```bash
sudo wget -O /usr/share/fonts/"MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
sudo wget -O /usr/share/fonts/"MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
sudo wget -O /usr/share/fonts/"MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
sudo wget -O /usr/share/fonts/"MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -fv
```

## Instalar powerlevel10k

[Repositorio de powerlevel10k](https://github.com/romkatv/powerlevel10k)

Reemplazar `<user>` por el usuario no privilegiado

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k && echo 'source /home/$USER/powerlevel10k/powerlevel10k.zsh-theme' >> $HOME/.zshrc
```

Configurar la `zsh` tanto para el usuario no privilegiado como para `root`

```bash
zsh
```

| Configuración              | Opción |
| -------------------------- | ------ |
| Prompt Style               | 2      |
| Character Set              | 1      |
| Prompt Color               | 2      |
| Show current time?         | n      |
| Prompt Separators          | 1      |
| Prompt Heads               | 3      |
| Prompt Tails               | 4      |
| Prompt Height              | 1      |
| Prompt Spacing             | 2      |
| Icons                      | 2      |
| Prompt Flow                | 2      |
| Enable Transient Prompt?   | y      |
| Instant Prompt Mode        | 1      |
| Apply changes to ~/.zshrc? | y      |

```bash
sudo ln -s -f $HOME/.zshrc /root/.zshrc
sudo compaudit
chown root:root /usr/local/share/zsh/site-functions/_bspc
```

Descargar el archivo `https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/sudo/sudo.plugin.zsh`

```bash
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo/
sudo wget -P /usr/share/zsh/plugins/zsh-sudo/ https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/sudo/sudo.plugin.zsh
```

Modificar el archivo `$HOME/.zshrc` y agregar las siguientes líneas

```bash
nano $HOME/.zshrc
```

```bash
# Fix Java issue
export _JAVA_AWT_WM_NONREPARENTING=1

# ZSH AutoSuggestions plugin
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ZSH Syntax Highlighting plugin
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ZSH Sudo plugin
if [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
    source /usr/share/zsh-sudo/sudo.plugin.zsh
fi

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

htb(){
  opt=$1
  case $opt in
    a) sudo openvpn $HOME/academy-regular.ovpn ;;
    m) sudo openvpn $HOME/lab_n0m3l4c000nt35.ovpn ;;
    *) echo "Uso: htb a | m"
  esac
}

st(){
  ip_address=$1
  machine_name=$2
  echo "$ip_address $machine_name" > /home/<user>/.config/bin/target
}

ct(){
  echo "" > /home/<user>/.config/bin/target
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

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups sharehistory

# bat
alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'

# ls
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

# burpsuite
alias bs='/usr/bin/burpsuite 2>/dev/null & disown'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

Modificar el archivo `$HOME/.p10k.zsh` tanto para el usuario no privilegiado como para root comentando los plugins de la derecha de la zsh que no se quiere que aparezcan y agregar al lado izquierdo los que si se quiere que aparezcan

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

## Instalar picom

[Repositorio de picom](https://github.com/yshui/picom)

```bash
sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev cmake -y
git clone https://github.com/yshui/picom $HOME/Downloads/picom
meson setup --buildtype=release $HOME/Downloads/picom/build $HOME/Downloads/picom
ninja -C $HOME/Downloads/picom/build
sudo ninja -C $HOME/Downloads/picom/build install
rm -rf $HOME/Downloads/picom
which picom
mkdir $HOME/.config/picom
touch $HOME/.config/picom/picom.conf
```

Copiar el contenido del archivo [picom.sample.conf](https://raw.githubusercontent.com/yshui/picom/next/picom.sample.conf) al archivo `$HOME/.config/picom/picom.conf`

```bash
nano $HOME/.config/picom/picom.conf
```

Modificar las siguientes líneas del archivo `$HOME/.config/picom/picom.conf`

```bash
backend = "xrender"
detect-rounded-corners = false;
detect-client-opacity = true;
```

Comentar sombras y blur para que la performance mejore

Agregar al archivo `$HOME/.config/bspwm/bspwmrc` la línea `picom &`

```bash
nano $HOME/.config/bspwm/bspwmrc
```

```bash
picom &
```

## Instalar batcat y lsd

[Repositorio de batcat](https://github.com/sharkdp/bat)  
[Repositorio de lsd](https://github.com/lsd-rs/lsd)

```bash
wget -P $HOME/Downloads https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
wget -P $HOME/Downloads https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_amd64.deb
sudo dpkg -i $HOME/Downloads/bat_0.24.0_amd64.deb
sudo dpkg -i $HOME/Downloads/lsd_1.1.5_amd64.deb
rm $HOME/Downloads/bat_0.24.0_amd64.deb $HOME/Downloads/lsd_1.1.5_amd64.deb
```

## Instalar feh

[Repositorio de feh](https://github.com/derf/feh)

```bash
sudo apt install feh -y
```

Editar el archivo `$HOME/.config/bspwm/bspwmrc`

```bash
nano $HOME/.config/bspwm/bspwmrc
```

```bash
/usr/bin/feh --bg-center $HOME/Pictures/<wallpaper-name>.<extension>
```

## Instalar polybar

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
