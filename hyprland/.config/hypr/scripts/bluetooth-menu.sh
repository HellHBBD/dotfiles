#!/usr/bin/env bash
set -u

command -v bluetoothctl >/dev/null 2>&1 || exit 0
command -v fuzzel >/dev/null 2>&1 || exit 0

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "藍牙" "$1"
}

if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    power_action="󰂲 關閉藍牙"
else
    power_action="󰂯 開啟藍牙"
fi

selection=$({
    printf '%s\n' "$power_action" '󰂯 掃描裝置'
    bluetoothctl devices 2>/dev/null | sed 's/^Device / /'
} | fuzzel --dmenu --prompt '藍牙 > ') || exit 0

case $selection in
'󰂲 關閉藍牙')
    bluetoothctl power off >/dev/null && notify "藍牙已關閉"
    exit 0
    ;;
'󰂯 開啟藍牙')
    bluetoothctl power on >/dev/null && notify "藍牙已開啟"
    exit 0
    ;;
'󰂯 掃描裝置')
    bluetoothctl power on >/dev/null
    bluetoothctl --timeout 5 scan on >/dev/null 2>&1
    exec "$0"
    ;;
'')
    exit 0
    ;;
esac

address=${selection# }
address=${address%% *}
[[ $address =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]] || exit 0

info=$(bluetoothctl info "$address" 2>/dev/null || true)
name=$(sed -n 's/^\s*Name: //p' <<<"$info" | head -n 1)
[[ -n $name ]] || name=$address

if grep -q 'Connected: yes' <<<"$info"; then
    bluetoothctl disconnect "$address" >/dev/null && notify "已中斷與 $name 的連線"
    exit 0
fi

bluetoothctl pair "$address" >/dev/null 2>&1 || true
bluetoothctl trust "$address" >/dev/null 2>&1 || true
if bluetoothctl connect "$address" >/dev/null; then
    notify "已連線至 $name"
else
    notify "無法連線至 $name"
fi
