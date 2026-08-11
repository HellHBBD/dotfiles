#!/usr/bin/env bash
set -u

emit() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text: $text, class: $class, tooltip: $tooltip}'
}

if ! command -v bluetoothctl >/dev/null 2>&1; then
    emit " 錯誤" "error" "BlueZ 無法使用"
    exit 0
fi

if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    emit " 已關閉" "off" "藍牙已關閉"
    exit 0
fi

device=$(bluetoothctl devices Connected 2>/dev/null | sed -n 's/^Device [^ ]* //p' | head -n 1)
if [[ -z $device ]]; then
    emit " 未連線" "idle" "藍牙已開啟，沒有已連線的裝置"
    exit 0
fi

emit " $device" "connected" "已連線至：$device"
