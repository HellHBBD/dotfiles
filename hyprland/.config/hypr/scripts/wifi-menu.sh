#!/usr/bin/env bash
set -u

command -v nmcli >/dev/null 2>&1 || exit 0

choose() {
    fuzzel --dmenu --prompt "Wi-Fi: "
}

if [[ $(nmcli -t -f WIFI general status 2>/dev/null) != "enabled" ]]; then
    nmcli radio wifi on
fi

selection=$( {
    printf '%s\n' '󰖩 Disconnect' '󰖩 Rescan'
    nmcli --terse --fields SSID device wifi list --rescan yes 2>/dev/null | sed '/^$/d' | sort -u
} | choose) || exit 0

case $selection in
    '󰖩 Disconnect')
        nmcli device disconnect "$(nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')" 2>/dev/null || true
        ;;
    '󰖩 Rescan')
        nmcli device wifi rescan
        ;;
    '') exit 0 ;;
    *)
        if ! nmcli device wifi connect "$selection" 2>/dev/null; then
            password=$(fuzzel --dmenu --prompt-only "Password: " --password) || exit 0
            [[ -n $password ]] && nmcli device wifi connect "$selection" password "$password"
        fi
        ;;
esac
