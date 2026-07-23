#!/usr/bin/env bash
set -u

emit() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text: $text, class: $class, tooltip: $tooltip}'
}

if ! command -v nmcli >/dev/null 2>&1; then
    emit "󰖪 Error" "error" "NetworkManager is unavailable"
    exit 0
fi

if [[ $(nmcli -t -f WIFI general status 2>/dev/null) != "enabled" ]]; then
    emit "󰖪 Off" "off" "Wi-Fi is disabled"
    exit 0
fi

connection=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" { print $2 "|" $3; exit }')
if [[ -z $connection ]]; then
    emit "󰖩 Offline" "disconnected" "Wi-Fi is enabled but not connected"
    exit 0
fi

ssid=${connection%%|*}
signal=${connection##*|}
emit "󰤨 $ssid $signal%" "connected" "Connected: $ssid ($signal%)"
