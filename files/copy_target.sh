#!/bin/bash

echo -n "$(cat $HOME/.config/polybar/scripts/target.txt)" | xclip -sel clip
