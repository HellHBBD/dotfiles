#!/usr/bin/env bash
set -u

emit() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text: $text, class: $class, tooltip: $tooltip}'
}

read_number() {
    local value

    [[ -r $1 ]] || return 1
    value=$(<"$1")
    [[ $value =~ ^[0-9]+$ ]] || return 1
    printf '%s' "$value"
}

format_duration() {
    local minutes=$1

    if ((minutes < 60)); then
        printf '%d 分' "$minutes"
    else
        printf '%d 小時 %d 分' "$((minutes / 60))" "$((minutes % 60))"
    fi
}

battery_icon() {
    local capacity=$1
    local status=$2
    local level=$(((capacity + 9) / 10))
    local -a battery_icons=(
        '󰂎' '󰁺' '󰁻' '󰁼' '󰁽' '󰁾' '󰁿' '󰂀' '󰂁' '󰂂' '󰁹'
    )
    local -a charging_icons=(
        '󰢜' '󰢜' '󰂆' '󰂇' '󰂈' '󰢝' '󰂉' '󰢞' '󰂊' '󰂋' '󰂅'
    )

    if ((level > 10)); then
        level=10
    fi

    if [[ $status == 'Charging' ]]; then
        printf '%s' "${charging_icons[level]}"
    else
        printf '%s' "${battery_icons[level]}"
    fi
}

shopt -s nullglob
batteries=(/sys/class/power_supply/BAT*)
if ((${#batteries[@]} == 0)); then
    emit '' 'hidden' ''
    exit 0
fi

battery=${batteries[0]}
capacity=$(read_number "$battery/capacity" || true)
status=$(<"$battery/status")

if [[ ! $capacity =~ ^[0-9]+$ ]]; then
    emit '' 'hidden' ''
    exit 0
fi

class='normal'
if ((capacity <= 15)); then
    class='critical'
elif ((capacity <= 30)); then
    class='warning'
fi

case $status in
Charging)
    status_text='充電中'
    ;;
Discharging)
    status_text='使用電池'
    ;;
Full)
    status_text='已充滿'
    ;;
Not\ charging)
    status_text='已接電，未充電'
    ;;
*)
    status_text='狀態未知'
    ;;
esac

charge_now=$(read_number "$battery/charge_now" || true)
charge_full=$(read_number "$battery/charge_full" || true)
charge_design=$(read_number "$battery/charge_full_design" || true)
current_now=$(read_number "$battery/current_now" || true)
energy_now=$(read_number "$battery/energy_now" || true)
energy_full=$(read_number "$battery/energy_full" || true)
energy_design=$(read_number "$battery/energy_full_design" || true)
power_now=$(read_number "$battery/power_now" || true)

if [[ $charge_full =~ ^[0-9]+$ && $charge_design =~ ^[0-9]+$ ]] && ((charge_design > 0)); then
    health="$((charge_full * 100 / charge_design))%"
elif [[ $energy_full =~ ^[0-9]+$ && $energy_design =~ ^[0-9]+$ ]] && ((energy_design > 0)); then
    health="$((energy_full * 100 / energy_design))%"
else
    health='無法取得'
fi

estimate='-'
if [[ $status == 'Discharging' ]]; then
    if [[ $charge_now =~ ^[0-9]+$ && $current_now =~ ^[0-9]+$ ]] && ((current_now > 0)); then
        estimate=$(format_duration "$((charge_now * 60 / current_now))")
    elif [[ $energy_now =~ ^[0-9]+$ && $power_now =~ ^[0-9]+$ ]] && ((power_now > 0)); then
        estimate=$(format_duration "$((energy_now * 60 / power_now))")
    else
        estimate='無法估算'
    fi
elif [[ $status == 'Charging' ]]; then
    estimate='充電中'
fi

tooltip=$(printf '狀態：%s\n預估可用：%s\n健康度：%s' \
    "$status_text" "$estimate" "$health")

emit " $(battery_icon "$capacity" "$status") ${capacity}%" "$class" "$tooltip"
