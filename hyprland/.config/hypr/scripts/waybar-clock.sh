#!/usr/bin/env bash
set -u

weekday=("" "一" "二" "三" "四" "五" "六" "日")
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
weekday_index=$(date +%u)
first_weekday=$(date -d "$year-$month-01" +%u)
last_day=$(date -d "$year-$month-01 +1 month -1 day" +%d)

day=$((10#$day))
last_day=$((10#$last_day))

calendar="<tt>日  一  二  三  四  五  六</tt>"
cell=1
for ((week = 0; week < 6; week++)); do
    line="<tt>"

    for ((column = 1; column <= 7; column++, cell++)); do
        current_day=$((cell - first_weekday + 1))
        if ((current_day < 1 || current_day > last_day)); then
            line+="   "
        elif ((current_day == day)); then
            printf -v current "%2d" "$current_day"
            line+="<span foreground='#5c9cf5' weight='bold'>$current</span> "
        else
            printf -v current "%2d" "$current_day"
            line+="$current "
        fi
    done

    line+="</tt>"
    calendar+="\n$line"
    ((current_day >= last_day)) && break
done

text=$(date '+%m/%d %H:%M')
tooltip="<b>${year}年${month#0}月${day}日 星期${weekday[$weekday_index]}</b>\n$calendar"

if command -v jq >/dev/null 2>&1; then
    jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
else
    printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$text"
fi
