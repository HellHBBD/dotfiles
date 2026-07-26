#!/usr/bin/env bash
set -u

sheet_name='hyprland-keybind-cheatsheet'

notify_error() {
    local message=$1

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical 'Keybind cheat sheet' "$message"
    else
        printf 'Keybind cheat sheet: %s\n' "$message" >&2
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

    notify_error 'An existing Fuzzel instance did not close.'
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
    notify_error 'XDG_RUNTIME_DIR is unavailable.'
    exit 1
fi

for command in hyprctl jq fuzzel flock setsid; do
    if ! command -v "$command" >/dev/null 2>&1; then
        notify_error "Required command is unavailable: $command"
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
    notify_error 'Could not read monitor layout.'
    exit 1
}

read -r monitor_width monitor_height < <(printf '%s\n' "$monitor" | jq -r '
    first(.[] | select(.focused)) // .[0] | "\(.width) \(.height)"
')

if [[ ! $monitor_width =~ ^[0-9]+$ || ! $monitor_height =~ ^[0-9]+$ ]]; then
    notify_error 'Could not determine the focused monitor size.'
    exit 1
fi

left_column=$(printf '%s\n' \
    'APPLICATIONS' \
    'SUPER + /              Show cheat sheet' \
    'SUPER + D              Application launcher' \
    'SUPER + E              Open file manager' \
    'SUPER + SHIFT + Return Open browser' \
    'SUPER + V              Clipboard history' \
    '' \
    'SESSION' \
    'SUPER + N              Toggle notification center' \
    'SUPER + SHIFT + N      Toggle do-not-disturb' \
    'SUPER + L              Lock session' \
    'CTRL + ALT + Delete    Open power menu' \
    'SUPER + SHIFT + M      Exit graphical session' \
    '' \
    'WINDOW MANAGEMENT' \
    'SUPER + Return         Open terminal' \
    'SUPER + Q              Close active window' \
    'SUPER + F              Toggle fullscreen' \
    'SUPER + ALT + Space    Toggle floating' \
    'SUPER + Arrow keys     Focus window' \
    'SUPER + SHIFT + Arrows Move window' \
    'SUPER + Left click     Move window with mouse' \
    'SUPER + Right click    Resize window with mouse' \
    'ALT + Tab              Cycle to next window' \
    'SUPER + P              Toggle window pin' \
    'SUPER + Minus / Equal  Adjust split ratio' \
    'SUPER + T              Toggle split direction')

right_column=$(printf '%s\n' \
    'CAPTURE' \
    'SUPER + SHIFT + S      Copy selected screenshot' \
    'Print                  Copy full-screen screenshot' \
    'SUPER + SHIFT + C      Pick color' \
    '' \
    'WORKSPACES' \
    'SUPER + 1 through 0    Focus workspace 1 through 10' \
    'SUPER + ALT + 1..0     Move window to workspace' \
    'SUPER + SHIFT + 1..0   Move window and follow' \
    'CTRL + SUPER + Arrows  Previous or next workspace' \
    'SUPER + Mouse wheel    Previous or next workspace' \
    'SUPER + S              Toggle scratchpad' \
    'SUPER + ALT + S        Move window to scratchpad' \
    '' \
    'AUDIO, BRIGHTNESS, MEDIA' \
    'Volume keys            Increase or decrease volume' \
    'Mute key               Toggle output mute' \
    'Microphone mute key    Toggle microphone mute' \
    'Brightness keys        Increase or decrease brightness' \
    'Play or Pause key      Play or pause media' \
    'Next or Previous key   Change media track')

if ((monitor_width >= 1100 && monitor_height >= 680)); then
    sheet=$(paste -d ' ' \
        <(while IFS= read -r line; do printf '%-48s\n' "$line"; done <<< "$left_column") \
        <(printf '%s\n' "$right_column"))
    fuzzel_width=112
    fuzzel_lines=29
    fuzzel_line_height=20
else
    sheet=$(printf '%s\n\n%s\n' "$left_column" "$right_column")
    fuzzel_width=$((monitor_width / 10))
    ((fuzzel_width < 56)) && fuzzel_width=56
    ((fuzzel_width > 86)) && fuzzel_width=86
    fuzzel_lines=$(((monitor_height - 80) / 24))
    ((fuzzel_lines < 12)) && fuzzel_lines=12
    ((fuzzel_lines > 30)) && fuzzel_lines=30
    fuzzel_line_height=22
fi

sheet_file=$(mktemp "$runtime_dir/$sheet_name.XXXXXX") || {
    notify_error 'Could not create cheat sheet data.'
    exit 1
}
printf '%s\n' "$sheet" > "$sheet_file"

token="$$-$RANDOM-$RANDOM"
setsid "$0" --keybind-cheatsheet-run "$sheet_file" "$pid_file" "$token" "$lock_fd" \
    "$fuzzel_width" "$fuzzel_lines" "$fuzzel_line_height" &
controller_pid=$!
controller_start=$(process_start_time "$controller_pid")
printf '%s %s %s\n' "$controller_pid" "$controller_start" "$token" > "$pid_file"
