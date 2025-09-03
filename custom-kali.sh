#!/bin/bash

sudo apt install -y virtualbox-guest-x11 linux-headers-$(uname -r) xorg dkms build-essential bspwm kitty feh polybar picom rofi i3lock flameshot xclip firefox-esr ntpsec-ntpdate locate unzip openvpn
sudo updatedb

mkdir $HOME/Images
mkdir -p $HOME/.config/{bspwm,sxhkd,kitty,polybar,rofi,htb,picom}
mkdir $HOME/.config/bspwm/scripts
mkdir $HOME/.config/polybar/scripts
mkdir $HOME/.config/htb/{vpn,machines}
mkdir $HOME/htb/machines
sudo mkdir /opt/nvim
sudo mkdir /usr/share/fonts/truetype/hacknerd
sudo mkdir /usr/share/zsh-sudo

wget -P $HOME https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/.xinitrc
wget -P $HOME https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/.Xresources
wget -P $HOME/.config/bspwm/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/bspwmrc
wget -P $HOME/.config/sxhkd/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/sxhkdrc
wget -P $HOME/.config/polybar/scripts/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/ethernet_status.sh
wget -P $HOME/.config/polybar/scripts/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/vpn_status.sh
wget -P $HOME/.config/polybar/scripts/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/target_to_hack.sh
wget -P $HOME/.config/polybar/scripts/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/copy_target.sh
wget -P $HOME/.config/bspwm/scripts/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/bspwm_resize
wget -P $HOME/.config/polybar/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/launch.sh
wget -P $HOME/.config/polybar/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/config.ini
wget -P $HOME/.config/kitty/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/kitty.conf
wget -P $HOME/.config/kitty/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/Box.conf
wget -P $HOME/.config/rofi/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/config.rasi
wget -P $HOME/.config/rofi/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/box-theme.rasi
wget -P $HOME/.config/picom/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/picom.conf
wget -P $HOME/.config/eww/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/eww.yuck
wget -P $HOME/.config/eww/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/cheatsheet.yuck
wget -P $HOME/.config/eww/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/bar.yuck
wget -P $HOME/.config/eww/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/eww.scss
wget -P $HOME/.config/eww/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/cheatsheet.scss
wget -P $HOME/.config/eww/ https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/bar.scss

wget -qO- https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/refs/heads/main/files/.zshrc >> $HOME/.zshrc
sudo wget https://raw.githubusercontent.com/n0m3l4c000nt35/custom-kali-linux/main/htbash.sh -O /usr/bin/htbash

touch $HOME/.config/polybar/scripts/target.txt
touch $HOME/.config/htb/htbash.conf

chmod u+x $HOME/.config/bspwm/bspwmrc
chmod +x $HOME/.config/polybar/scripts/{ethernet_status.sh,vpn_status.sh,target_to_hack.sh,copy_target.sh}
chmod +x $HOME/.config/bspwm/scripts/bspwm_resize
chmod +x $HOME/.config/polybar/launch.sh
sudo chmod +x /usr/bin/htbash

sudo wget -P /usr/share/fonts/truetype/hacknerd https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
sudo unzip /usr/share/fonts/truetype/hacknerd/Hack.zip -d /usr/share/fonts/truetype/hacknerd
sudo rm /usr/share/fonts/truetype/hacknerd/LICENSE.md /usr/share/fonts/truetype/hacknerd/README.md /usr/share/fonts/truetype/hacknerd/Hack.zip

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

sudo wget -P /usr/share/zsh-sudo/ https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh

wget -P $HOME/Downloads https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
wget -P $HOME/Downloads https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_amd64.deb
sudo dpkg -i $HOME/Downloads/bat_0.25.0_amd64.deb
sudo dpkg -i $HOME/Downloads/lsd_1.1.5_amd64.deb
rm $HOME/Downloads/bat_0.25.0_amd64.deb $HOME/Downloads/lsd_1.1.5_amd64.deb

git clone https://github.com/NvChad/starter $HOME/.config/nvim
wget -P $HOME/Downloads https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz
sudo mv $HOME/Downloads/nvim-linux-x86_64.tar.gz /opt/nvim
sudo tar -xf /opt/nvim/nvim-linux-x86_64.tar.gz -C /opt/nvim
sudo rm /opt/nvim/nvim-linux-x86_64.tar.gz
sudo ln -s /opt/nvim/nvim-linux-x86_64/bin/nvim /usr/bin/nvim

git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install --key-bindings --completion --update-rc

sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy
sudo make -C /opt/i3lock-fancy install

startx
