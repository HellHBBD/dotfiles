#!/usr/bin/env bash
set -u

sheet_name='hyprland-keybind-cheatsheet'

notify_error() {
    local message=$1

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical '快捷鍵總覽' "$message"
    else
        printf '快捷鍵總覽：%s\n' "$message" >&2
    fi
}

process_start_time() {
    awk '{ print $22 }' "/proc/$1/stat" 2>/dev/null
}

process_group() {
    awk '{ print $5 }' "/proc/$1/stat" 2>/dev/null
}

sheet_pids() {
    local namespace=$1
    local args comm pid proc

    for proc in /proc/[0-9]*; do
        pid=${proc##*/}
        [[ -r $proc/comm && -r $proc/cmdline ]] || continue
        read -r comm < "$proc/comm" || continue
        [[ $comm == fuzzel ]] || continue
        args=$(tr '\0' ' ' < "$proc/cmdline")

        if [[ $args == *"--namespace=$namespace"* ]]; then
            printf '%s\n' "$pid"
        fi
    done
}

fuzzel_pids() {
    local comm pid proc

    for proc in /proc/[0-9]*; do
        pid=${proc##*/}
        [[ -r $proc/comm ]] || continue
        read -r comm < "$proc/comm" || continue

        if [[ $comm == fuzzel ]]; then
            printf '%s\n' "$pid"
        fi
    done
}

close_existing_fuzzel() {
    local attempt pid
    local -a active_pids

    mapfile -t active_pids < <(fuzzel_pids)
    for pid in "${active_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
    done

    for ((attempt = 0; attempt < 50; attempt++)); do
        if [[ -z $(fuzzel_pids) ]]; then
            return 0
        fi
        sleep 0.05
    done

    notify_error '已有 Fuzzel 視窗無法關閉。'
    return 1
}

run_sheet() {
    local sheet_file=$1
    local pid_file=$2
    local token=$3
    local width=$4
    local lines=$5
    local line_height=$6
    local namespace="$sheet_name-$token"
    local launcher_pid launch_attempts=0 seen_fuzzel=0

    cleanup() {
        local stored_pid stored_start stored_token

        if read -r stored_pid stored_start stored_token < "$pid_file" && [[ $stored_token == "$token" ]]; then
            rm -f "$pid_file"
        fi
        rm -f "$sheet_file"
    }

    trap cleanup EXIT
    trap 'exit 0' INT TERM

    if command -v uwsm >/dev/null 2>&1 &&
        systemctl --user is-active --quiet 'wayland-session@*.target'; then
        uwsm app -- fuzzel --dmenu --only-match --no-icons --no-sort --hide-prompt \
            --match-mode=exact --namespace="$namespace" --width="$width" \
            --lines="$lines" --line-height="$line_height" < "$sheet_file" &
    else
        fuzzel --dmenu --only-match --no-icons --no-sort --hide-prompt \
            --match-mode=exact --namespace="$namespace" --width="$width" \
            --lines="$lines" --line-height="$line_height" < "$sheet_file" &
    fi
    launcher_pid=$!

    while :; do
        if [[ -n $(sheet_pids "$namespace") ]]; then
            seen_fuzzel=1
        elif ((seen_fuzzel)); then
            break
        elif ! kill -0 "$launcher_pid" 2>/dev/null && ((launch_attempts >= 20)); then
            break
        fi
        ((launch_attempts++))
        sleep 0.1
    done

    cleanup
    trap - EXIT
}

if [[ ${1:-} == '--keybind-cheatsheet-run' ]]; then
    lock_fd=$5
    if [[ ! $lock_fd =~ ^[0-9]+$ ]]; then
        exit 1
    fi
    exec {lock_fd}>&-
    run_sheet "$2" "$3" "$4" "$6" "$7" "$8"
    exit 0
fi

if [[ -z ${XDG_RUNTIME_DIR:-} ]]; then
    notify_error 'XDG_RUNTIME_DIR 無法使用。'
    exit 1
fi

for command in column hyprctl jq fuzzel flock setsid; do
    if ! command -v "$command" >/dev/null 2>&1; then
        notify_error "找不到必要指令：$command"
        exit 1
    fi
done

runtime_dir=$XDG_RUNTIME_DIR
pid_file="$runtime_dir/$sheet_name.pid"
lock_file="$runtime_dir/$sheet_name.lock"
exec {lock_fd}>"$lock_file"
flock -n "$lock_fd" || exit 0

if [[ -s $pid_file ]]; then
    controller_pid=
    controller_start=
    token=
    read -r controller_pid controller_start token < "$pid_file" || true

    if [[ $token =~ ^[0-9]+-[0-9]+-[0-9]+$ ]]; then
        namespace="$sheet_name-$token"
        mapfile -t active_pids < <(sheet_pids "$namespace")
    else
        active_pids=()
    fi

    if ((${#active_pids[@]})); then
        for pid in "${active_pids[@]}"; do
            kill "$pid" 2>/dev/null || true
        done
        exit 0
    fi

    controller_args=$(tr '\0' ' ' < "/proc/${controller_pid:-0}/cmdline" 2>/dev/null || true)
    if [[ $controller_pid =~ ^[0-9]+$ ]] &&
        [[ $controller_start == "$(process_start_time "$controller_pid")" ]] &&
        [[ $controller_pid == "$(process_group "$controller_pid")" ]] &&
        [[ $controller_args == *"--keybind-cheatsheet-run"* ]] &&
        [[ $controller_args == *"$token"* ]]; then
        kill -- "-$controller_pid" 2>/dev/null || true
        exit 0
    fi

    rm -f "$pid_file"
fi

close_existing_fuzzel || exit 1

monitor=$(hyprctl -j monitors 2>/dev/null) || {
    notify_error '無法取得螢幕配置。'
    exit 1
}

read -r monitor_width monitor_height < <(printf '%s\n' "$monitor" | jq -r '
    first(.[] | select(.focused)) // .[0] | "\(.width) \(.height)"
')

if [[ ! $monitor_width =~ ^[0-9]+$ || ! $monitor_height =~ ^[0-9]+$ ]]; then
    notify_error '無法判定目前螢幕尺寸。'
    exit 1
fi

left_column=$(printf '%s\n' \
    $'應用程式\t' \
    $'SUPER + /\t顯示快捷鍵總覽' \
    $'SUPER + D\t開啟應用程式啟動器' \
    $'SUPER + E\t開啟檔案管理員' \
    $'SUPER + SHIFT + Return\t開啟瀏覽器' \
    $'SUPER + V\t剪貼簿歷史紀錄' \
    $'\t' \
    $'工作階段\t' \
    $'SUPER + N\t切換通知中心' \
    $'SUPER + SHIFT + N\t切換勿擾模式' \
    $'SUPER + L\t鎖定工作階段' \
    $'CTRL + ALT + Delete\t開啟電源選單' \
    $'SUPER + SHIFT + M\t結束圖形工作階段' \
    $'\t' \
    $'視窗管理\t' \
    $'SUPER + Return\t開啟終端機' \
    $'SUPER + Q\t關閉目前視窗' \
    $'SUPER + F\t切換全螢幕' \
    $'SUPER + ALT + Space\t切換浮動視窗' \
    $'SUPER + 方向鍵\t聚焦視窗' \
    $'SUPER + SHIFT + 方向鍵\t移動視窗' \
    $'SUPER + 滑鼠左鍵\t移動視窗' \
    $'SUPER + 滑鼠右鍵\t調整視窗大小' \
    $'ALT + Tab\t切換至下一個視窗' \
    $'SUPER + P\t切換視窗置頂' \
    $'SUPER + Minus / Equal\t調整分割比例' \
    $'SUPER + T\t切換分割方向')

right_column=$(printf '%s\n' \
    $'螢幕擷取\t' \
    $'SUPER + SHIFT + S\t複製選取區域截圖' \
    $'Print\t複製全螢幕截圖' \
    $'SUPER + SHIFT + C\t擷取色彩' \
    $'\t' \
    $'工作區\t' \
    $'SUPER + 1 至 0\t聚焦工作區 1 至 10' \
    $'SUPER + ALT + 1..0\t移動視窗至工作區' \
    $'SUPER + SHIFT + 1..0\t移動視窗並跟隨' \
    $'CTRL + SUPER + 方向鍵\t上一個或下一個工作區' \
    $'SUPER + 滑鼠滾輪\t上一個或下一個工作區' \
    $'SUPER + S\t切換暫存視窗' \
    $'SUPER + ALT + S\t移動視窗至暫存區' \
    $'\t' \
    $'音效、亮度與媒體\t' \
    $'音量鍵\t調高或調低音量' \
    $'靜音鍵\t切換輸出靜音' \
    $'麥克風靜音鍵\t切換麥克風靜音' \
    $'亮度鍵\t調高或調低亮度' \
    $'播放或暫停鍵\t播放或暫停媒體' \
    $'下一首或上一首鍵\t切換媒體曲目')

format_sheet() {
    column -s $'\t' -t -o '    '
}

if ((monitor_width >= 1100 && monitor_height >= 680)); then
    sheet=$(paste -d $'\t' \
        <(printf '%s\n' "$left_column") \
        <(printf '%s\n' "$right_column") | format_sheet)
    fuzzel_width=112
    fuzzel_lines=29
    fuzzel_line_height=20
else
    sheet=$(printf '%s\n\n%s\n' "$left_column" "$right_column" | format_sheet)
    fuzzel_width=$((monitor_width / 10))
    ((fuzzel_width < 56)) && fuzzel_width=56
    ((fuzzel_width > 86)) && fuzzel_width=86
    fuzzel_lines=$(((monitor_height - 80) / 24))
    ((fuzzel_lines < 12)) && fuzzel_lines=12
    ((fuzzel_lines > 30)) && fuzzel_lines=30
    fuzzel_line_height=22
fi

sheet_file=$(mktemp "$runtime_dir/$sheet_name.XXXXXX") || {
    notify_error '無法建立快捷鍵資料。'
    exit 1
}
printf '%s\n' "$sheet" > "$sheet_file"

token="$$-$RANDOM-$RANDOM"
setsid "$0" --keybind-cheatsheet-run "$sheet_file" "$pid_file" "$token" "$lock_fd" \
    "$fuzzel_width" "$fuzzel_lines" "$fuzzel_line_height" &
controller_pid=$!
controller_start=$(process_start_time "$controller_pid")
printf '%s %s %s\n' "$controller_pid" "$controller_start" "$token" > "$pid_file"
