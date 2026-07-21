#!/usr/bin/env bash
set -u

selection=$(slurp) || exit 0
[[ -n $selection ]] || exit 0

directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$directory"
file="$directory/$(date '+%Y-%m-%d_%H-%M-%S').png"

if grim -g "$selection" "$file"; then
    wl-copy < "$file"
    notify-send "Screenshot saved" "$file"
else
    notify-send -u critical "Screenshot failed" "grim could not capture the selected area"
    exit 1
fi
