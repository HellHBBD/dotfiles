#!/usr/bin/env bash
set -u

sheet_name='hyprland-keybind-cheatsheet'
prompt='Keybinds > '

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
        uwsm app -- fuzzel --dmenu --match-mode=fzf --prompt "$prompt" --namespace="$namespace" < "$sheet_file" &
    else
        fuzzel --dmenu --match-mode=fzf --prompt "$prompt" --namespace="$namespace" < "$sheet_file" &
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
    run_sheet "$2" "$3" "$4"
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

binds=$(hyprctl -j binds 2>/dev/null) || {
    notify_error 'Could not read active Hyprland bindings.'
    exit 1
}

sheet=$(printf '%s\n' "$binds" | jq -r '
    def mask: (.modmask? // 0 | tonumber);
    def has_modifier($bit): ((mask / $bit | floor) % 2 == 1);
    def modifiers:
        [
            if has_modifier(4) then "CTRL" else empty end,
            if has_modifier(8) then "ALT" else empty end,
            if has_modifier(1) then "SHIFT" else empty end,
            if has_modifier(64) then "SUPER" else empty end
        ] | join(" + ");
    def key:
        if (.key? | type) == "string" and .key != "" then .key
        else (.keycode? // "") | tostring
        end;
    def description:
        if (.description? | type) == "string" and .description != "" then .description
        elif (.allow_input_capture? | type) == "string" then .allow_input_capture
        else "(" + (.dispatcher // "unknown") + ") " + (.arg // "")
        end | gsub("[\\r\\n\\t]+"; " ");
    map({ key: ([modifiers, key] | map(select(length > 0)) | join(" + ")), description: description })
    | sort_by(.key, .description)[]
    | "\(.key)\t\(.description)"
' 2>/dev/null) || sheet=$(printf '%s\n' "$binds" | awk '
    function value(line) {
        sub(/^[^:]*:[[:space:]]*/, "", line)
        sub(/,[[:space:]]*$/, "", line)
        sub(/^"/, "", line)
        sub(/"$/, "", line)
        return line
    }
    function has(bit) { return int(modmask / bit) % 2 == 1 }
    function emit(   modifiers) {
        if (key == "") return
        modifiers = ""
        if (has(4)) modifiers = "CTRL"
        if (has(8)) modifiers = modifiers (modifiers ? " + " : "") "ALT"
        if (has(1)) modifiers = modifiers (modifiers ? " + " : "") "SHIFT"
        if (has(64)) modifiers = modifiers (modifiers ? " + " : "") "SUPER"
        print modifiers (modifiers ? " + " : "") key "\t" description
    }
    /^[[:space:]]*\{/ { emit(); modmask = 0; key = ""; description = ""; next }
    /"submap":/ { modmask = value($0); next }
    /"keycode":/ { key = value($0); next }
    /"allow_input_capture":/ { description = value($0); next }
    END { emit() }
' | LC_ALL=C sort)

if [[ -z $sheet ]]; then
    notify_error 'Hyprland reported no active bindings.'
    exit 1
fi

sheet_file=$(mktemp "$runtime_dir/$sheet_name.XXXXXX") || {
    notify_error 'Could not create cheat sheet data.'
    exit 1
}
printf '%s\n' "$sheet" > "$sheet_file"

token="$$-$RANDOM-$RANDOM"
setsid "$0" --keybind-cheatsheet-run "$sheet_file" "$pid_file" "$token" "$lock_fd" &
controller_pid=$!
controller_start=$(process_start_time "$controller_pid")
printf '%s %s %s\n' "$controller_pid" "$controller_start" "$token" > "$pid_file"
