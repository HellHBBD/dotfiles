#!/usr/bin/env bash
set -u

command -v bluetoothctl >/dev/null 2>&1 || exit 0

if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    bluetoothctl power on >/dev/null
fi

selection=$( {
    printf '%s\n' '󰂯 Scan for devices'
    bluetoothctl devices 2>/dev/null | sed -n 's/^Device \([^ ]*\) \(.*\)$/\1  \2/p'
} | fuzzel --dmenu --prompt "Bluetooth: ") || exit 0

[[ -z $selection ]] && exit 0
if [[ $selection == '󰂯 Scan for devices' ]]; then
    bluetoothctl --timeout 5 scan on >/dev/null 2>&1
    exec "$0"
fi

address=${selection%% *}
info=$(bluetoothctl info "$address" 2>/dev/null || true)
if grep -q 'Connected: yes' <<<"$info"; then
    bluetoothctl disconnect "$address"
else
    bluetoothctl pair "$address" >/dev/null 2>&1 || true
    bluetoothctl trust "$address" >/dev/null 2>&1 || true
    bluetoothctl connect "$address"
fi
