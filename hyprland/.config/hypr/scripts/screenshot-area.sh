#!/usr/bin/env bash
set -u

selection=$(slurp) || exit 0
[[ -n $selection ]] || exit 0

directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$directory"
file="$directory/$(date '+%Y-%m-%d_%H-%M-%S').png"

if grim -g "$selection" "$file"; then
    wl-copy <"$file"
    notify-send "截圖已儲存" "$file"
else
    notify-send -u critical "截圖失敗" "grim 無法擷取選取區域"
    exit 1
fi
