#!/usr/bin/env bash
set -u

command -v bluetoothctl >/dev/null 2>&1 || exit 0
command -v fuzzel >/dev/null 2>&1 || exit 0

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Bluetooth" "$1"
}

if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    power_action="󰂲 Turn Bluetooth off"
else
    power_action="󰂯 Turn Bluetooth on"
fi

selection=$({
    printf '%s\n' "$power_action" '󰂯 Scan for devices'
    bluetoothctl devices 2>/dev/null | sed 's/^Device / /'
} | fuzzel --dmenu --prompt 'Bluetooth > ') || exit 0

case $selection in
'󰂲 Turn Bluetooth off')
    bluetoothctl power off >/dev/null && notify "Bluetooth turned off"
    exit 0
    ;;
'󰂯 Turn Bluetooth on')
    bluetoothctl power on >/dev/null && notify "Bluetooth turned on"
    exit 0
    ;;
'󰂯 Scan for devices')
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
    bluetoothctl disconnect "$address" >/dev/null && notify "Disconnected from $name"
    exit 0
fi

bluetoothctl pair "$address" >/dev/null 2>&1 || true
bluetoothctl trust "$address" >/dev/null 2>&1 || true
if bluetoothctl connect "$address" >/dev/null; then
    notify "Connected to $name"
else
    notify "Could not connect to $name"
fi
