#!/usr/bin/env bash
set -u

emit() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text: $text, class: $class, tooltip: $tooltip}'
}

if ! command -v bluetoothctl >/dev/null 2>&1; then
    emit " BT Error" "error" "BlueZ is unavailable"
    exit 0
fi

if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    emit " BT Off" "off" "Bluetooth is disabled"
    exit 0
fi

device=$(bluetoothctl devices Connected 2>/dev/null | sed -n 's/^Device [^ ]* //p' | head -n 1)
if [[ -z $device ]]; then
    emit " BT On" "idle" "Bluetooth is enabled with no connected device"
    exit 0
fi

emit " $device" "connected" "Connected: $device"
