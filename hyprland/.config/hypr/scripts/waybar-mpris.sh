#!/usr/bin/env bash
set -u

player=$(playerctl -l 2>/dev/null | head -n 1 || true)

if [[ -z $player ]]; then
    printf '%s\n' '{"text":"󰝛 No media","tooltip":"No MPRIS player is available"}'
    exit 0
fi

status=$(playerctl --player="$player" status 2>/dev/null || true)
artist=$(playerctl --player="$player" metadata artist 2>/dev/null || true)
title=$(playerctl --player="$player" metadata title 2>/dev/null || true)

if [[ -z $title ]]; then
    title="Unknown title"
fi

icon="󰐊"
[[ $status == "Paused" ]] && icon="󰏤"

jq -cn --arg text "$icon $artist${artist:+ - }$title" --arg tooltip "$player: $status" '{text: $text, tooltip: $tooltip}'
