#!/usr/bin/env bash
set -u

if ! command -v nmcli >/dev/null 2>&1; then
    printf '%s\n' '{"text":"󰖪","tooltip":"NetworkManager is unavailable"}'
    exit 0
fi

if [[ $(nmcli -t -f WIFI general status 2>/dev/null) != "enabled" ]]; then
    printf '%s\n' '{"text":"󰖪","tooltip":"Wi-Fi is disabled"}'
    exit 0
fi

connection=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" { print $2 "|" $3; exit }')
if [[ -z $connection ]]; then
    printf '%s\n' '{"text":"󰖩","tooltip":"Wi-Fi enabled, not connected"}'
    exit 0
fi

ssid=${connection%%|*}
signal=${connection##*|}
jq -cn --arg text "󰤨 $ssid" --arg tooltip "Wi-Fi: $ssid ($signal%)" '{text: $text, tooltip: $tooltip}'
