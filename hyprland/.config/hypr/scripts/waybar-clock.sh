#!/usr/bin/env bash
set -u

text=$(date '+%m/%d %H:%M')
tooltip="<tt>$(cal)</tt>"

if command -v jq >/dev/null 2>&1; then
    jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
else
    printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$text"
fi
