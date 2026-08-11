#!/usr/bin/env bash
set -u

emit() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text: $text, class: $class, tooltip: $tooltip}'
}

if ! command -v nmcli >/dev/null 2>&1; then
    emit "󰖪 錯誤" "error" "NetworkManager 無法使用"
    exit 0
fi

wired_device=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null |
    awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }')
if [[ -n $wired_device ]]; then
    wired_connection=$(nmcli -g GENERAL.CONNECTION device show "$wired_device" 2>/dev/null)
    [[ -n $wired_connection && $wired_connection != "--" ]] || wired_connection=$wired_device
    emit "󰈀 $wired_connection" "connected" "有線網路：$wired_connection（$wired_device）"
    exit 0
fi

if [[ $(nmcli -t -f WIFI general status 2>/dev/null) != "enabled" ]]; then
    emit "󰖪 已關閉" "off" "Wi-Fi 已關閉"
    exit 0
fi

connection=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" { print $2 "|" $3; exit }')
if [[ -z $connection ]]; then
    emit "󰖩 未連線" "disconnected" "Wi-Fi 已開啟但未連線"
    exit 0
fi

ssid=${connection%%|*}
signal=${connection##*|}
emit "󰤨 $ssid $signal%" "connected" "已連線至：$ssid（訊號 $signal%）"
