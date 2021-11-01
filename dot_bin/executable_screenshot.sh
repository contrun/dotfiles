#!/usr/bin/env bash
file="$HOME/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png"
if [[ -z "$WAYLAND_DISPLAY" ]]; then
    maim -s "$file"
else
    grimshot save area "$file"
fi

if [[ "$?" -eq "0" ]]; then
    noti -t "screenshot" -m "saved to $file"
fi
