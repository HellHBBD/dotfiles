#!/usr/bin/env bash
set -u

text=$(date '+%m/%d %H:%M')
today=$(date '+%-d')
calendar=$(cal --color=never | awk -v today="$today" '
    NR <= 2 {
        print
        next
    }

    {
        for (column = 1; column <= length($0); column += 3) {
            day = substr($0, column, 2)
            if (day ~ /^[[:space:]]*[0-9][0-9]?$/ && day + 0 == today) {
                $0 = substr($0, 1, column - 1) \
                    "<span foreground=\"#1e1e2e\" background=\"#89b4fa\" weight=\"bold\">" \
                    day "</span>" substr($0, column + 2)
                break
            }
        }
        print
    }
')
tooltip="<tt>$calendar</tt>"

if command -v jq >/dev/null 2>&1; then
    jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
else
    printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$text"
fi
