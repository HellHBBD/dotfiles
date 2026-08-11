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
    power_action="󰖪 關閉 Wi-Fi"
else
    power_action="󰖩 開啟 Wi-Fi"
fi

selection=$({
    printf '%s\n' "$power_action" '󰖩 中斷連線' '󰑓 重新掃描'
    if wifi_enabled; then
        nmcli --terse --fields SSID device wifi list --rescan yes 2>/dev/null |
            sed '/^$/d' |
            sort -u
    fi
} | fuzzel --dmenu --prompt 'Wi-Fi > ') || exit 0

case $selection in
'󰖪 關閉 Wi-Fi')
    nmcli radio wifi off && notify "Wi-Fi 已關閉"
    ;;
'󰖩 開啟 Wi-Fi')
    nmcli radio wifi on && notify "Wi-Fi 已開啟"
    ;;
'󰖩 中斷連線')
    device=$(connected_device)
    if [[ -n $device ]]; then
        nmcli device disconnect "$device" && notify "已中斷連線"
    else
        notify "沒有作用中的 Wi-Fi 連線"
    fi
    ;;
'󰑓 重新掃描')
    nmcli device wifi rescan && notify "已要求掃描網路"
    ;;
'')
    exit 0
    ;;
*)
    if nmcli device wifi connect "$selection"; then
        notify "已連線至 $selection"
        exit 0
    fi

    password=$(fuzzel --dmenu --prompt-only 'Wi-Fi 密碼 > ' --password) || exit 0
    [[ -n $password ]] || exit 0
    if nmcli device wifi connect "$selection" password "$password"; then
        notify "已連線至 $selection"
    else
        notify "無法連線至 $selection"
    fi
    ;;
esac
