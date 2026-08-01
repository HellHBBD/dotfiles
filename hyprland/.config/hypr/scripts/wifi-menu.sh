#!/usr/bin/env bash
set -u

command -v nmcli >/dev/null 2>&1 || exit 0
command -v fuzzel >/dev/null 2>&1 || exit 0

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Wi-Fi" "$1"
}

wifi_enabled() {
    [[ $(nmcli -t -f WIFI general status 2>/dev/null) == "enabled" ]]
}

connected_device() {
    nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null |
        awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }'
}

if wifi_enabled; then
    power_action="󰖪 Turn Wi-Fi off"
else
    power_action="󰖩 Turn Wi-Fi on"
fi

selection=$({
    printf '%s\n' "$power_action" '󰖩 Disconnect' '󰑓 Rescan'
    if wifi_enabled; then
        nmcli --terse --fields SSID device wifi list --rescan yes 2>/dev/null |
            sed '/^$/d' |
            sort -u
    fi
} | fuzzel --dmenu --prompt 'Wi-Fi > ') || exit 0

case $selection in
'󰖪 Turn Wi-Fi off')
    nmcli radio wifi off && notify "Wi-Fi turned off"
    ;;
'󰖩 Turn Wi-Fi on')
    nmcli radio wifi on && notify "Wi-Fi turned on"
    ;;
'󰖩 Disconnect')
    device=$(connected_device)
    if [[ -n $device ]]; then
        nmcli device disconnect "$device" && notify "Disconnected"
    else
        notify "No active Wi-Fi connection"
    fi
    ;;
'󰑓 Rescan')
    nmcli device wifi rescan && notify "Network scan requested"
    ;;
'')
    exit 0
    ;;
*)
    if nmcli device wifi connect "$selection"; then
        notify "Connected to $selection"
        exit 0
    fi

    password=$(fuzzel --dmenu --prompt-only 'Wi-Fi password > ' --password) || exit 0
    [[ -n $password ]] || exit 0
    if nmcli device wifi connect "$selection" password "$password"; then
        notify "Connected to $selection"
    else
        notify "Could not connect to $selection"
    fi
    ;;
esac
