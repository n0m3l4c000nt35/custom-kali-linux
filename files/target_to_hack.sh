#!/bin/bash

ip_address=$(/bin/cat $HOME/.config/polybar/scripts/target.txt)

if [ -n "$ip_address" ]; then
  echo "%{T2}%{F#ff0000}<U+F04FE>%{T-} %{F#fff}$ip_address"
else
  echo ""
fi
