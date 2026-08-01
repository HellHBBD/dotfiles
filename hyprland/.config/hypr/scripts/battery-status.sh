#!/usr/bin/env bash
set -u

emit() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text: $text, class: $class, tooltip: $tooltip}'
}

shopt -s nullglob
batteries=(/sys/class/power_supply/BAT*)
if (( ${#batteries[@]} == 0 )); then
    emit '' 'hidden' ''
    exit 0
fi

battery=${batteries[0]}
capacity=$(<"$battery/capacity")
status=$(<"$battery/status")

if [[ ! $capacity =~ ^[0-9]+$ ]]; then
    emit '' 'hidden' ''
    exit 0
fi

class='normal'
if (( capacity <= 15 )); then
    class='critical'
elif (( capacity <= 30 )); then
    class='warning'
fi

case $status in
Charging)
    icon='󰂄'
    ;;
Full|Not\ charging)
    icon='󰚥'
    ;;
*)
    icon='󰁹'
    ;;
esac

emit "$icon ${capacity}%" "$class" "$status: ${capacity}%"
