<div align=center>
	<h1>Instalación y personalización de Kali Linux</h1>
</div>

![Kali Linux](https://www.kali.org/wallpapers/images/2024/kali-ferrofluid.jpg)

> [!NOTE]
> En Virtual Box

## Configuración de la máquina virtual

![vm-general](https://github.com/user-attachments/assets/9cb614b8-18d3-4e4d-bb10-df72d16744e2)  
El portapapeles compartido bidireccional

![vm-audio](https://github.com/user-attachments/assets/0d313a83-7558-4782-bf3b-943dfe756dc1)  
El audio deshabilitado ya que no lo uso para nada

![vm-red](https://github.com/user-attachments/assets/e67c4f68-5f86-438e-9c1d-04f5e6a80a0a)  
Adaptador puente habilitado

> [!warning]
> No seleccionar ningún software a instalar

![software-selection](https://github.com/user-attachments/assets/17e9a9d8-4138-48fe-ad02-ffb5c4031033)

- [Actualización](#actualización)
- [Instalación de paquetes](#instalación-de-paquetes)
- [Creación de directorios](#creación-de-directorios)
- [Creación de archvivos](#creación-de-archvivos)
- [Permisos](#permisos)
- [.xinitrc](#xinitrc)
- [.Xresources](#xresources)
- [Fuentes](#fuentes)
- [bspwm](#bspwm)
	- [bspwmrc](#bspwmrc)
	- [bspwm_resize](#bspwm_resize)
	- [sxhkdrc](#sxhkdrc)
- [Picom](#picom)
	- [picom.conf](#picomconf)
- [Kitty](#kitty)
	- [kitty.conf](#kittyconf)
- [Powerlevel10k](#powerlevel10k)
	- [.p10k.zsh](#p10kzsh)
- [zsh](#zsh)
	- [.zshrc](#zshrc)
	- [zsh-sudo](#zsh-sudo)
- [batcat y lsd](#batcat-y-lsd)
- [Rofi](#rofi)
	- [config.rasi](#configrasi)
	- [box-theme.rasi](#box-themerasi)
- [Polybar](#polybar)
	- [launch.sh](#launchsh)
	- [config.ini](#configini)
	- [ethernet_status.sh](#ethernet_statussh)
	- [vpn_status.sh](#vpn_statussh)
	- [target_to_hack.sh](#target_to_hacksh)
	- [copy_target.sh](#copy_targetsh)
- [nvim y nvchad](#nvim-y-nvchad)
	- [Markdown Preview Plugin](#markdown-preview-plugin)
- [fzf](#fzf)
- [i3lock](#i3lock)
- [Configurar git](#configurar-git)
- [Node](#node)
- [Docker](#docker)
- [Python 2.7](#python-27)
- [Otras configuraciones](#otras-configuraciones)
- [htbash](#htbash)

## Actualización

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

> [!tip]
> Después de actualizar, upgradear y reiniciar, ejecutá este comando para ahorrarte un poco de tiempo:

```bash
wget https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/custom-kali.sh && chmod +x custom-kali.sh && ./custom-kali.sh
```

1. Una vez que el script finalice vas a ver la pantalla negra con la polybar, presioná las teclas `super` + `enter` para abrir la kitty. Lo primero que se va a ejecutar es la configuración de la `powerlevel10k`, configurala a gusto
2. Modificá el archivo `.p10k.zsh` con las indicaciones del README
3. Agregá las líneas faltantes al archivo `.zshrc` del README
4. Chequeá que todo lo demás esté instalado y personalizado

✅ [DONE!](#debería-quedarte-así)

> [!NOTE]
> O podés hacerlo a mano a partir de acá ⬇️

## Instalación de paquetes

```bash
sudo apt install -y virtualbox-guest-x11 linux-headers-$(uname-r) xorg dkms build-essential bspwm kitty feh polybar picom rofi i3lock flameshot xclip firefox-esr ntpsec-ntpdate locate unzip openvpn
sudo updatedb
```

## Creación de directorios

```bash
mkdir -p $HOME/.config/{bspwm,sxhkd,kitty,polybar,rofi,htb}
mkdir $HOME/.config/bspwm/scripts
mkdir $HOME/.config/polybar/scripts
mkdir $HOME/.config/htb/{vpn,machines}
mkdir $HOME/htb/machines
sudo mkdir /opt/nvim
sudo mkdir /usr/share/fonts/truetype/hacknerd
sudo mkdir /usr/share/zsh-sudo
```

## Creación de archvivos

```bash
touch $HOME/.xinitrc
touch $HOME/.Xresources
touch $HOME/.config/bspwm/bspwmrc
touch $HOME/.config/sxhkd/sxhkdrc
touch $HOME/.config/polybar/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh,copy_target.sh,target.txt}
touch $HOME/.config/bspwm/scripts/bspwm_resize
touch $HOME/.config/polybar/{launch.sh,config.ini}
```

## Permisos

```bash
chmod +x $HOME/.xinitrc
chmod u+x $HOME/.config/bspwm/bspwmrc
chmod +x $HOME/.config/polybar/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh,copy_target.sh}
chmod +x $HOME/.config/bspwm/scripts/bspwm_resize
chmod +x $HOME/.config/polybar/launch.sh
```

## .xinitrc

```bash
nano $HOME/.xinitrc
```

[.xinitrc](/files/.xinitrc)

## .Xresources

Modifica el cursor

```bash
nano $HOME/.Xresources
```

[.Xresources](/files/.Xresources)

## Fuentes

```bash
sudo wget -P /usr/share/fonts/truetype/hacknerd https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
sudo unzip /usr/share/fonts/truetype/hacknerd/Hack.zip -d /usr/share/fonts/truetype/hacknerd
sudo rm /usr/share/fonts/truetype/hacknerd/LICENSE.md /usr/share/fonts/truetype/hacknerd/README.md /usr/share/fonts/truetype/hacknerd/Hack.zip
```

## bspwm

### bspwmrc

```bash
nano $HOME/.config/bspwm/bspwmrc
```

[bspwmrc](/files/bspwmrc)

### bspwm_resize

```bash
nano $HOME/.config/bspwm/scripts/bspwm_resize
```

[bspwm_resize](/files/bspwm_resize)

### sxhkdrc

```bash
nano $HOME/.config/sxhkd/sxhkdrc
```

[sxhkdrc](/files/sxhkdrc)

## picom

### picom.conf

```bash
nano $HOME/.config/picom/picom.conf
```

[picom.conf](/files/picom.conf)

## kitty

Seleccionar el theme de preferencia y seleccionar la opción `Place the theme file in /home/kali/.config/kitty but do not modify kitty.conf`. En mi caso seleccioné el theme `Box` y agregué la línea `include Box.conf` al archivo `kitty.conf` como se muestra a continuación.

```bash
kitten themes
```

### kitty.conf

```bash
nano $HOME/.config/kitty/kitty.conf
```

[kitty.conf](/files/kitty.conf)

## powerlevel10k

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
p10k configure
```

### .p10k.zsh

```bash
nano $HOME/.p10k.zsh
```

Modificar `<kali-linux` por el ícono de kali de la web [Nerd Fonts](https://www.nerdfonts.com/cheat-sheet).

```bash
# Modificar la siguiente sección para que quede de esta manera
# The list of segments shown on the left. Fill it with the most important segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # os identifier
    dir                     # current directory
    vcs                     # git status
    prompt_char             # prompt symbol
    context
    command_execution_time
    status
  )

# Comentar `context`, `command_execution_time` y `status` de la siguiente sección, de esta manera quedaran solo del lado izquierdo
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(

# Esta línea es para agregar un espacio a la derecha del ícono de Kali para separarlo un poco del ícono de la carpeta que representa la ruta $HOME, la tenés que descomentar
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='<kali-icon> '
```

Una vez configurado el archivo `.p10k.zsh` ejecutar el comando `source $HOME/.p10k.zsh` para aplicar los cambios inmediatamente

## zsh

### .zshrc

> [!warning]
> Agregar las siguientes líneas al archivo sin eliminar nada

```bash
nano $HOME/.zshrc
```

[.zshrc](/files/.zshrc)

### zsh-sudo

Plugin de la zsh que al presionar dos veces la tecla `esc` agrega `sudo` al principio de un comando que se está escribiendo

```bash
sudo wget -P /usr/share/zsh-sudo/ https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
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

## Rofi

### config.rasi

[config.rasi](/files/config.rasi)

### box-theme.rasi

[config.rasi](/files/box-theme.rasi)

## Polybar

[Repositorio de polybar](https://github.com/polybar/polybar)

### launch.sh

```bash
nano $HOME/.config/polybar/launch.sh
```

[launch.sh](/files/launch.sh)

### config.ini

```bash
nano $HOME/.config/polybar/config.ini
```

[config.ini](/files/config.ini)

### ethernet_status.sh

```bash
nano $HOME/.config/polybar/scripts/ethernet_status.sh
```

[ethernet_status](/files/ethernet_status.sh)

### vpn_status.sh

```bash
nano $HOME/.config/polybar/scripts/vpn_status.sh
```

[vpn_status](/files/vpn_status.sh)

### target_to_hack.sh

```bash
nano $HOME/.config/polybar/scripts/target_to_hack.sh
```

[target_to_hack.sh](/files/target_to_hack.sh)

### copy_target.sh

```bash
nano $HOME/.config/polybar/scripts/copy_target.sh
```

[copy_target.sh](/files/copy_target.sh)

> [!tip]
> Antes de instalar `nvim` se recomienda instalar `node` porque hay algunos plugins de `nvim` que dependen de `node` si no, después de instalar `node` hay que volver a ejecutar el comando `MasonInstallAll` dentro de `nvim`

## nvim y nvchad

Chequear si `nvim` está instalado

```bash
which nvim
```

Si `nvim` está instalado, desinstalarlo y eliminar el binario

```bash
sudo apt remove nvim
sudo rm /usr/bin/nvim
```

[Repositorio de nvchad](https://github.com/NvChad/NvChad)  
[Página oficial de nvchad](https://nvchad.com/docs/quickstart/install/)  
[Repositorio de nvim](https://github.com/neovim/neovim)

```bash
git clone https://github.com/NvChad/starter $HOME/.config/nvim
wget -P $HOME/Downloads https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz
sudo mv $HOME/Downloads/nvim-linux-x86_64.tar.gz /opt/nvim
sudo tar -xf /opt/nvim/nvim-linux-x86_64.tar.gz -C /opt/nvim
sudo rm /opt/nvim/nvim-linux-x86_64.tar.gz
sudo ln -s /opt/nvim/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
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

Ejecutar el comando `:MasonInstallAll` en `nvim`

```bash
nvim
```

Presionar `shift` + `:` e ingresar

```bash
MasonInstallAll
```

### Markdown Preview Plugin

> [!WARNING]
> Es necesario instalar `node` antes

[Repositorio de Markdown Preview for (Neo)vim](https://github.com/iamcco/markdown-preview.nvim)

Copiar las siguientes líneas en el archivo `$HOME/.config/nvim/lua/plugins/init.lua`

```bash
nvim $HOME/.config/nvim/lua/plugins/init.lua
```

```bash
{
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
},
```

Salir de `nvim` y al volver a entrar se va a instalar el plugin. Probar abrir un archivo `.md` y ejecutar el comando `MarkdownPreview` dentro de `nvim` presionando las teclas `shift` + `:` e ingresar el comando `MarkdownPreview` y presionar `enter`.

## fzf

[Repositorio de fzf](https://github.com/junegunn/fzf)

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install --key-bindings --completion --update-rc
```

## i3lock

```bash
sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy
sudo make -C /opt/i3lock-fancy install
```

## Configurar git

```bash
git config --global user.name "<username>"
git config --global user.email "<email>"
git config --global core.editor "code --wait"
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm "commit -m"
```

## Node

[Descargar Node.js](https://nodejs.org/es/download)

## Docker

[Descargar Docker](https://docs.docker.com/engine/install/debian/)

## Python 2.7

```bash
sudo nano /etc/apt/sources.list
# Agregar la siguiente línea al archivo /etc/apt/sources.list
deb http://archive.debian.org/debian/ stretch contrib main non-free
sudo apt-get update
sudo apt-get install python2.7
```

## Otras configuraciones

Para que Firefox resuelva los dominios de `hack the box` ingresar en la barra de navegación `about:config`, ingresar `browser.fixup.domainsuffixwhitelist.htb` y ponerlo en `true`

Navegador predeterminado

```bash
nano $HOME/.config/mimeapps.list
```

```bash
[Default Applications]
x-scheme-handler/http=firefox-esr.desktop
x-scheme-handler/https=firefox-esr.desktop
text/html=firefox-esr.desktop
```

<div align=center>
	<h2>Debería quedarte así</h2>
</div>

![kitty](https://github.com/user-attachments/assets/02cb3a86-0716-4109-9788-d0614dd22096)

![firefox](https://github.com/user-attachments/assets/ceb846b0-5ffc-4553-9848-cc1ec14692b6)

![help](https://github.com/user-attachments/assets/ffdf93f2-5e61-47bd-abd4-91535bf7f4d4)

![rofi](https://github.com/user-attachments/assets/1a53b916-d588-4756-a119-579a6c3efd73)

![htbash](https://github.com/user-attachments/assets/31a261ba-41ce-4bd8-9c45-826addcfe3d3)

## htbash

[Github](https://github.com/n0m3l4c000nt35/htbash)

> Script para listar máquinas de Hack The Box, ver información de una máquina en particular y crear un pequeño entorno para jugar a una máquina seleccionada

### Obtener API

[https://app.hackthebox.com/profile/settings](https://app.hackthebox.com/profile/settings)  
Ingresar al profile

![create_app_token](https://github.com/user-attachments/assets/dde17259-e2e9-46c9-a1b6-b0b7c78ccc84)  
Hacer click en CREATE APP TOKEN

![create](https://github.com/user-attachments/assets/23311420-54c3-4b47-9bf3-8810edeef0ab)  
Modificar el TOKEN NAME, seleccionar EXPIRES IN 1 Year

![copy_token](https://github.com/user-attachments/assets/a564be50-a441-4f07-86a2-9a4f060bc04d)  
Copiar el token y guardarlo en el archivo `$HOME/.config/htb/machines/htbash.conf`

![helppanel](https://github.com/user-attachments/assets/33236802-fb35-4a17-8dce-2d44fbde9520)

Agregar en el archivo `$HOME/.zshrc` tu nombre de usuario en Hack The Box

```bash
nano $HOME/.zshrc
```

```bash
export HTB_USER="u53rn4m3"
```

Agregar la siguiente línea al archivo `/etc/sudoers` para que al ejecutar el script y conectarse a la VPN no te pida contraseña.

```bash
sudo visudo
```

```bash
<tu-usuario>	ALL=(ALL:ALL) NOPASSWD: /usr/sbin/openvpn /home/kali/.config/htb/vpn/*.ovpn
```

Descargar los siguientes archivos para conectarte a la VPN de Hack The Box y guardarlos en el directorio `$HOME/.config/htb/vpn`

- competitive_\<tu-usuario\>.ovpn
- lab_\<tu-usuario\>.ovpn

<div align=center>
	💡 <a href="https://www.linkedin.com/in/esteban-zarate/">Ideas?</a> ✅ <a href="https://www.linkedin.com/in/esteban-zarate/">Sugerencias?</a> ✅ <a href="https://www.linkedin.com/in/esteban-zarate/">Errores?</a> ✅ <a href="https://www.linkedin.com/in/esteban-zarate/">Mejoras?</a> 💡
</div>
