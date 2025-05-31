#!/bin/sh

ETH=$(ip -4 a show eth0 | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+')

if [ -n "$ETH" ]; then
  echo "%{T2}%{F#2494e7}󰈀%{T-} %{F#fff}$(ip -4 a show eth0 | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+')"
else
  echo "%{T2}%{F#808080}󰈀%{T-} %{F#fff} Ups!"
fi
