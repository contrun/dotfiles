#!/usr/bin/env bash
file="$HOME/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png"
maim -s "$file"
if [[ "$?" -eq "0" ]]; then
    notifications.sh "saved to $file" "screenshot"
    echo "$file"
fi
