# Personalización de Linux

1. [Instalar bspwm](#Instalar-bspwm)
2. [Instalar sxhkd](#Instalar-sxhkd)
3. [Instalar kitty](#Instalar-kitty)
4. [Instalar zsh](#Instalar-zsh)
5. [Instalar fuentes](#Instalar-fuentes)
6. [Instalar powerlevel10k](#Instalar-powerlevel10k)
7. [Instalar picom](#Instalar-picom)
8. [Instalar batcat y lsd](#Instalar-batcat-y-lsd)
9. [Instalar feh](#Instalar-feh)
10. [Instalar polybar](#Instalar-polybar)
11. [Instalar imagemagick](#Instalar-imagemagick)
12. [Instalar nvim y nvchad](#Instalar-nvim-y-nvchad)
13. [Instalar fzf](#Instalar-fzf)
14. [Instalar i3lock](#Instalar-i3lock)
15. [Instalar locate](#Instalar-locate)
16. [Instalar rofi](#Instalar-rofi)

## Instalar bspwm

[Repositorio de bspwm](https://github.com/baskerville/bspwm)

```bash
sudo apt install libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev -y
```

```bash
git clone https://github.com/baskerville/bspwm.git ~/Downloads/bspwm
git clone https://github.com/baskerville/sxhkd.git ~/Downloads/sxhkd
sudo make -C ~/Downloads/bspwm
sudo make -C ~/Downloads/bspwm install
which bspwm
```

Agregar la siguiente línea al archivo `~/.config/bspwm/bspwmrc`

```bash
vi ~/.config/bspwm/bspwmrc
```

```bash
bspc config border_width        1
bspc config focused_border_color "#ff1493"
bspc config normal_border_color "#750843"
```

## Instalar sxhkd

[Repositorio de sxhkd](https://github.com/baskerville/sxhkd)

```bash
sudo make -C ~/Downloads/sxhkd
sudo make -C ~/Downloads/sxhkd install
which sxhkd
```

Crear archivos de configuración de `bspwm` y `sxhkd`

```bash
mkdir ~/.config/{bspwm,sxhkd}
cp ~/Downloads/bspwm/examples/bspwmrc ~/.config/bspwm/
chmod u+x ~/.config/bspwm/bspwmrc
sudo apt install bspwm -y
cp ~/Downloads/bspwm/examples/sxhkdrc ~/.config/sxhkd/
rm -rf ~/Downloads/{bspwm,sxhkd}
```

Modificar las siguientes líneas del archivo `~/.config/sxhkd/sxhkdrc`

```bash
vi ~/.config/sxhkd/sxhkdrc
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
  ~/.config/bspwm/scripts/bspwm_resize {west,south,north,east}
```

Eliminar las siguientes líneas del archivo `~/.config/sxhkd/sxhkdrc`

```bash
vi ~/.config/sxhkd/sxhkdrc
```

```bash
# expand a window by moving one of its side outward
super + alt + {h,j,k,l}
  bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

# contract a window by moving one of its side inward
super + alt + shift + {h,j,k,l}
  bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}
```

Crear el script `~/.config/bspwm/scripts/bspwm_resize`

```bash
mkdir ~/.config/bspwm/scripts
touch ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/bspwm/scripts/bspwm_resize
```

Agregarle el siguiente contenido al archivo `~/.config/bspwm/scripts/bspwm_resize`

```bash
vi ~/.config/bspwm/scripts/bspwm_resize
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

Para poder copiar de manera bidireccional entre la máquina host y la máquina virtual, agregar la siguiente línea al archivo `~/.config/bspwm/bspwmrc`

```bash
echo "vmware-user-suid-wrapper &" >> ~/.config/bspwm/bspwmrc
```

Agregar el siguiente bind al archivo `~/.config/sxhkd/sxhkdrc` para abrir `firefox`

```bash
vi ~/.config/sxhkd/sxhkdrc
```

```bash
# open firefox
super + shift + f
  /usr/bin/firefox

# open chromium
super + shift + g
  /usr/bin/chromium
```

Para que Firefox resuelva los dominios de `hack the box` ingresar en la barra de navegación `about:config`, ingresar `browser.fixup.domainsuffixwhitelist.htb` y ponerlo en `true`

## Instalar kitty

[Repositorio de kitty](https://github.com/kovidgoyal/kitty)

```bash
sudo mkdir /opt/kitty && wget -O- https://github.com/kovidgoyal/kitty/releases/download/v0.36.4/kitty-0.36.4-x86_64.txz | sudo tar -xJ -C /opt/kitty && sudo ln -s /opt/kitty/bin/kitty /usr/bin/kitty && sudo ln -s /opt/kitty/bin/kitten /usr/bin/kitten
```

Modificar las siguientes líneas al archivo `~/.config/sxhkd/sxhkdrc`

```bash
vi ~/.config/sxhkd/sxhkdrc
```

```bash
# terminal emulator
super + Return
	/usr/bin/kitty
```

Crear el archivo `~/.config/kitty/kitty.conf` y agregarle el siguiente contenido

```bash
mkdir -p ~/.config/kitty && touch ~/.config/kitty/kitty.conf && vi ~/.config/kitty/kitty.conf
```

```bash
font_family HackNerdFont
cursor_shape beam

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

map ctrl+shift+z toggle_layout stack
tab_bar_style powerline

inactive_tab_background #e06c75
active_tab_background #98c379
inactive_tab_foreground #000000
tab_bar_margin_color black

background_opacity 0.90
```

```bash
sudo mkdir -p /root/.config/kitty && sudo ln -s ~/.config/kitty/kitty.conf /root/.config/kitty/kitty.conf
```

Crear acceso a **kitty**

```bash
sudo nano /usr/share/applications/kitty.desktop
```

```bash
[Desktop Entry]
Name=Kitty
Comment=A fast, feature-rich, GPU based terminal emulator
Exec=kitty
Icon=/opt/kitty/share/icons/hicolor/256x256/apps/kitty.png
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
```

```bash
sudo update-desktop-database
```

Seleccionar el tema de kitty

```bash
kitten themes
```

## Instalar zsh

```shell
sudo apt install zsh -y
sudo apt install zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete
ls -l /usr/share/ | grep zsh
sudo usermod --shell /usr/bin/zsh biff
sudo usermod --shell /usr/bin/zsh root
cat /etc/passwd | grep -E "^root|^biff"
```

Agregar la siguiente línea al archivo `~/.config/kitty/kitty.conf`

```shell
vi ~/.config/kitty/kitty.conf
```

```shell
shell zsh
```

## Instalar fuentes

[Nerd Fonts](https://www.nerdfonts.com/font-downloads)

```shell
sudo bash -c 'wget -P /usr/local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && 7z x /usr/local/share/fonts/Hack.zip -o/usr/local/share/fonts && rm -rf /usr/local/share/fonts/{Hack.zip,README.md,LICENSE.md} && git clone https://github.com/VaughnValle/blue-sky.git /tmp/blue-sky && cp /tmp/blue-sky/polybar/fonts/* /usr/share/fonts/truetype && fc-cache -v && rm -rf /tmp/blue-sky'
```

## Instalar powerlevel10k

[Repositorio de powerlevel10k](https://github.com/romkatv/powerlevel10k)

Reemplazar `<user>` por el usuario no privilegiado

```shell
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k && echo 'source /home/<user>/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
```

Configurar la `zsh` tanto para el usuario no privilegiado como para `root`

```shell
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

```shell
sudo ln -s -f ~/.zshrc /root/.zshrc
sudo compaudit
chown root:root /usr/local/share/zsh/site-functions/_bspc
```

Modificar el archivo `~/.zshrc` y agregar las siguientes líneas

```shell
vi ~/.zshrc
```

```shell
# Fix Java issue
export _JAVA_AWT_WM_NONREPARENTING=1

# ZSH AutoSuggestions Plugin
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ZSH Syntax Highlighting Plugin
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ZSH AutoComplete Plugin
if [ -f /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]; then
	source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
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

function settarget(){
  ip_address=$1
  machine_name=$2
  echo "$ip_address $machine_name" > /home/parrot/.config/bin/target
}

function cleartarget(){
  echo "" > /home/parrot/.config/bin/target
}

function mkt(){
	mkdir {nmap,content,exploits,scripts}
}

function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
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

# Custom Aliases
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

xset r rate 250 25
```

Modificar el archivo `~/.p10k.zsh` tanto para el usuario no privilegiado como para root comentando los plugins de la derecha de la zsh que no se quiere que aparezcan y agregar al lado izquierdo los que si se quiere que aparezcan

```shell
vi ~/.p10k.zsh
```

Modificar `<icon>` por un ícono a elección de la web [Nerd Fonts](https://www.nerdfonts.com/cheat-sheet)

```shell
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

```shell
sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev cmake -y
git clone https://github.com/yshui/picom ~/Downloads/picom
meson setup --buildtype=release ~/Downloads/picom/build ~/Downloads/picom
ninja -C ~/Downloads/picom/build
sudo ninja -C ~/Downloads/picom/build install
rm -rf ~/Downloads/picom
which picom
mkdir ~/.config/picom
touch ~/.config/picom/picom.conf
```

Copiar el contenido del archivo [picom.sample.conf](https://raw.githubusercontent.com/yshui/picom/next/picom.sample.conf) al archivo `~/.config/picom/picom.conf`

```shell
vi ~/.config/picom/picom.conf
```

Modificar las siguientes líneas del archivo `~/.config/picom/picom.conf`

```bash
backend = "xrender"
detect-rounded-corners = false;
detect-client-opacity = true;
```

Comentar sombras y blur para que la performance mejore

Agregar al archivo `~/.config/bspwm/bspwmrc` la línea `picom &`

```shell
vi ~/.config/bspwm/bspwmrc
```

```shell
picom &
```

## Instalar batcat y lsd

[Repositorio de batcat](https://github.com/sharkdp/bat)  
[Repositorio de lsd](https://github.com/lsd-rs/lsd)

```shell
wget -P ~/Downloads https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb && wget -P ~/Downloads https://github.com/lsd-rs/lsd/releases/download/v1.1.2/lsd_1.1.2_amd64.deb && sudo dpkg -i ~/Downloads/bat_0.24.0_amd64.deb && sudo dpkg -i ~/Downloads/lsd_1.1.2_amd64.deb && rm ~/Downloads/bat_0.24.0_amd64.deb ~/Downloads/lsd_1.1.2_amd64.deb
```

## Instalar feh

[Repositorio de feh](https://github.com/derf/feh)

```shell
sudo apt install feh -y
```

Editar el archivo `~/.config/bspwm/bspwmrc`

```shell
vi ~/.config/bspwm/bspwmrc
```

```shell
/usr/bin/feh --bg-center $HOME/Pictures/<wallpaper-name>.<extension>
```

## Enlace simbólico ifconfig

```bash
sudo ln -s /usr/sbin/ifconfig /usr/bin/ifconfig
```

## Instalar polybar

[Repositorio de polybar](https://github.com/polybar/polybar)

```shell
sudo apt install polybar -y
echo '~/.config/polybar/./launch.sh &' >> ~/.config/bspwm/bspwmrc
```

En el archivo `~/.config/polybar/launch.sh` agregar las siguientes líneas

```shell
vi ~/.config/polybar/launch.sh
```

```shell
#!/bin/bash

killall -q polybar

polybar main -c ~/.config/polybar/config.ini
```

```shell
touch ~/.config/bspwm/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh}
chmod +x ~/.config/bspwm/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh}
```

Agregar al archivo `~/.config/bspwm/scripts/ethernet_status.sh` el siguiente contenido

```shell
vi ~/.config/bspwm/scripts/ethernet_status.sh
```

```shell
#!/bin/sh

echo " %{F#fff}$(/usr/sbin/ifconfig ens33 | grep "inet " | awk '{print $2}')"
```

Agregar al archivo `~/.config/bspwm/scripts/vpn_status.sh` el siguiente contenido

```shell
vi ~/.config/bspwm/scripts/vpn_status.sh
```

```shell
#!/bin/sh

IFACE=$(/usr/sbin/ifconfig | grep tun0 | awk '{print $1}' | tr -d ':')

if [ "$IFACE" = "tun0" ]; then
    echo " %{F#fff}$(/usr/sbin/ifconfig tun0 | grep "inet " | awk '{print $2}')"
else
  echo " %{F#fff}Disconnected"
fi
```

Agregar al archivo `~/.config/bspwm/scripts/target_to_hack.sh` el siguiente contenido

```shell
vi ~/.config/bspwm/scripts/target_to_hack.sh
```

```shell
#!/bin/bash

ip_address=$(/bin/cat ~/.config/bin/target | awk '{print $1}')
machine_name=$(/bin/cat ~/.config/bin/target | awk '{print $2}')

if [ $ip_address ] && [ $machine_name ]; then
  echo " %{F#fff}$ip_address%{u-} - $machine_name"
else
  echo "%{u-}%{F#fff} No target"
fi
```

Crear el archivo `~/.config/bin/target`

```shell
mkdir ~/.config/bin
touch ~/.config/bin/target
```

Agregar al archivo `~/.config/polybar/current.ini` las siguientes líneas

```shell
vi ~/.config/polybar/config.ini
```

```shell
[bar/main]
width = 98%
height = 40
offset-x = 1%
offset-y = 1%
margin-bottom = 0
background = #00000000
module-margin = 5pt
modules-left = ethernet_status vpn_status
modules-center = workspaces
modules-right = target_to_hack
padding = 20px
font-0 = "Hack Nerd Font Mono:style=regular:size=10;1"
font-1 = "Hack Nerd Font Mono:style=regular:size=16;2"
font-2 = "Hack Nerd Font Mono:style=regular:size=18;2"
font-3 = "Hack Nerd Font Mono:style=regular:size=20;4"

[module/ethernet_status]
type = custom/script
exec = ~/.config/bspwm/scripts/ethernet_status.sh
interval = 2
format-prefix = "󰈀"
format-prefix-foreground = #2494e7
format-prefix-font = 2

[module/vpn_status]
type = custom/script
exec = ~/.config/bspwm/scripts/vpn_status.sh
interval = 2
format-prefix = "󰆧"
format-prefix-foreground = #1bbf3e
format-prefix-font = 2

[module/workspaces]
type = internal/xworkspaces
icon-default = 
format = <label-state>
format-font = 3
label-active = 󱓇
label-active-foreground = #1bbf3e
label-active-padding = 5px
label-active-font = 4
label-occupied = %icon%
label-occupied-foreground = #ffff00
label-occupied-padding = 5px
label-occupied-font = 2
label-urgent = %icon%
label-urgent-foreground = #e51d0b
label-urgent-padding = 5px
label-empty = %icon%
label-empty-foreground = #a1a1a1
label-empty-padding = 5px
label-empty-font = 2

[module/target_to_hack]
type = custom/script
exec = ~/.config/bspwm/scripts/target_to_hack.sh
interval = 2
format-prefix = "󰓾"
format-prefix-foreground = #e51d0b
format-prefix-font = 2
```

## Instalar imagemagick

[Repositorio de imagemagick](https://github.com/ImageMagick/ImageMagick)

```shell
sudo apt install imagemagick -y
```

Agregar al archivo `~/.config/bspwm/bspwmrc` la siguiente línea para las aplicaciones JAVA

```shell
vi ~/.config/bspwm/bspwmrc
```

```shell
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

```shell
git clone https://github.com/NvChad/starter ~/.config/nvim && wget -P ~/Downloads https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz && sudo mkdir /opt/nvim && sudo mv ~/Downloads/nvim-linux64.tar.gz /opt/nvim && sudo tar -xf /opt/nvim/nvim-linux64.tar.gz -C /opt/nvim && sudo rm /opt/nvim/nvim-linux64.tar.gz && sudo ln -s /opt/nvim/nvim-linux64/bin/nvim /usr/bin/nvim
```

Ejecutar los siguientes comandos para finalizar la instación de `nvim`

```shell
nvim
```

Agregar la siguiente línea al archivo `~/.config/nvim/init.lua` para eliminar el signo dolar/peso `$` en `nvim`

```shell
nvim ~/.config/nvim/init.lua
```

```shell
vim.opt.listchars = "tab:»·,trail:·"
```

Agregar la línea `transparency = true` al archivo `~/.config/nvim/lua/chadrc.lua` para agregarle transparencia

```shell
nvim ~/.config/nvim/lua/chadrc.lua
```

Debería quedar así

```shell
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

```shell
nvim
```

```shell
:MasonInstallAll
```

Ejecutar los siguientes comandos para que el usuario `root` también tenga la misma configuración para `nvim`

```shell
sudo mkdir /root/.config/nvim && sudo cp -r ~/.config/nvim/* /root/.config/nvim && sudo su
```

```bash
nvim
```

Ejecutar el siguiente comando como `root` en nvim `:MasonInstallAll`

```shell
nvim
```

```shell
:MasonInstallAll
```

## Instalar fzf

[Repositorio de fzf](https://github.com/junegunn/fzf)
Instalar `fzf` tanto como usuario no privilegiado como `root`

```shell
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

## Instalar i3lock

```shell
sudo apt install i3lock -y
sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy
sudo make -C /opt/i3lock-fancy install
```

Agregar las siguientes líneas al archivo `~/.config/sxhkd/sxhkdrc`

```bash
nvim ~/.config/sxhkd/sxhkdrc
```

```bash
# i3lock-fancy
super + shift + x
  /usr/bin/i3lock-fancy
```

## Instalar locate

```shell
sudo apt install locate && sudo updatedb
```

## Instalar rofi

```shell
sudo apt install rofi
mkdir ~/.config/rofi/themes
sudo git clone https://github.com/newmanls/rofi-themes-collection /opt/rofi-themes-collection
sudo cp /opt/rofi-themes-collection/themes ~/.config/rofi/themes
```

Modificar el archivo `~/.config/sxhkd/sxhkdrc`

```shell
nvim ~/.config/sxhkd/sxhkdrc
```

```
# program launcher
super + d
  /usr/bin/rofi -show run
```
