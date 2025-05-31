#!/bin/bash

killall -q polybar

polybar main -c $HOME/.config/polybar/config.ini
