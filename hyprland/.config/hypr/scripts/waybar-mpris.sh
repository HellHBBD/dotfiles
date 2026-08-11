#!/usr/bin/env bash
set -u

format_duration() {
    local seconds=${1%.*}
    [[ $seconds =~ ^[0-9]+$ ]] || seconds=0
    printf '%d:%02d' "$((seconds / 60))" "$((seconds % 60))"
}

active_player() {
    local player
    local first_player=""
    local status

    while IFS= read -r player; do
        [[ -n $player ]] || continue
        status=$(playerctl --player="$player" status 2>/dev/null || true)
        [[ -n $first_player ]] || first_player=$player
        if [[ $status == "Playing" ]]; then
            printf '%s\n' "$player"
            return
        fi
    done < <(playerctl -l 2>/dev/null)

    printf '%s\n' "$first_player"
}

if ! command -v playerctl >/dev/null 2>&1; then
    printf '%s\n' '{"text":"󰝛 No media","class":"idle","tooltip":"playerctl is unavailable"}'
    exit 0
fi

player=$(active_player)
if [[ -z $player ]]; then
    printf '%s\n' '{"text":"󰝛 No media","class":"idle","tooltip":"No MPRIS player is available"}'
    exit 0
fi

if (($# > 0)); then
    case $1 in
    play-pause | previous | next)
        exec playerctl --player="$player" "$1"
        ;;
    *)
        exit 2
        ;;
    esac
fi

status=$(playerctl --player="$player" status 2>/dev/null || true)
artist=$(playerctl --player="$player" metadata artist 2>/dev/null || true)
title=$(playerctl --player="$player" metadata title 2>/dev/null || true)
position=$(playerctl --player="$player" position 2>/dev/null || true)
length_us=$(playerctl --player="$player" metadata mpris:length 2>/dev/null || true)

[[ -n $title ]] || title="Unknown title"
[[ $length_us =~ ^[0-9]+$ ]] || length_us=0
length=$((length_us / 1000000))
position_seconds=${position%.*}
[[ $position_seconds =~ ^[0-9]+$ ]] || position_seconds=0

if ((length > 0)); then
    progress=$((position_seconds * 10 / length))
    ((progress > 10)) && progress=10
else
    progress=0
fi

filled=$(printf '%*s' "$progress" '')
empty=$(printf '%*s' "$((10 - progress))" '')
filled=${filled// /█}
empty=${empty// /░}

case $status in
Playing)
    icon="󰏤"
    class="playing"
    ;;
Paused)
    icon="󰐊"
    class="paused"
    ;;
*)
    icon="󰐊"
    class="idle"
    ;;
esac

text="$icon $artist${artist:+ - }$title"
tooltip="$artist${artist:+ - }$title\n$player: ${status:-Unknown}\n$filled$empty $(format_duration "$position_seconds") / $(format_duration "$length")"
jq -cn --arg text "$text" --arg class "$class" --arg tooltip "$tooltip" \
    '{text: $text, class: $class, tooltip: $tooltip}'
