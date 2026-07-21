#!/usr/bin/env bash
set -u

if ! command -v bluetoothctl >/dev/null 2>&1; then
    printf '%s\n' '{"text":"󰂲","tooltip":"BlueZ is unavailable"}'
    exit 0
fi

if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    printf '%s\n' '{"text":"󰂲","tooltip":"Bluetooth is disabled"}'
    exit 0
fi

device=$(bluetoothctl devices Connected 2>/dev/null | sed -n 's/^Device \([^ ]*\) \(.*\)$/\2/p' | head -n 1)
if [[ -z $device ]]; then
    printf '%s\n' '{"text":"","tooltip":"Bluetooth enabled, no connected device"}'
    exit 0
fi

jq -cn --arg text " $device" --arg tooltip "Connected: $device" '{text: $text, tooltip: $tooltip}'
