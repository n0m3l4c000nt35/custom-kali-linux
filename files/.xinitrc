#!/bin/bash

VBoxClient --vmsvga -d &
VBoxClient --clipboard -d &

xset r rate 250 25
setxkbmap latam

export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
xsetroot -cursor_name left_ptr &

[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

$HOME/.config/polybar/launch.sh &
wmname LG3D &

exec bspwm
