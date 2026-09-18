#!/usr/bin/env bash

# Save visible Hyprland clients before leaving the session, then restore their
# launchers to the same workspaces on the next Hyprland start.

set -u -o pipefail

readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland"
readonly STATE_FILE="$STATE_DIR/workspace-session.json"
readonly STATE_VERSION=1

require_commands() {
    command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1
}

log() {
    command -v logger >/dev/null 2>&1 && logger -t hypr-workspace-session -- "$*"
}

use_uwsm() {
    command -v uwsm >/dev/null 2>&1 &&
        systemctl --user is-active --quiet 'wayland-session@*.target'
}

desktop_entry_for_class() {
    local window_class=$1
    local desktop_file
    local startup_class

    for desktop_file in \
        "$HOME/.local/share/applications"/*.desktop \
        /usr/local/share/applications/*.desktop \
        /usr/share/applications/*.desktop; do
        [[ -f "$desktop_file" ]] || continue
        startup_class="$(awk -F= '$1 == "StartupWMClass" { print substr($0, index($0, "=") + 1); exit }' "$desktop_file")"
        [[ "$startup_class" == "$window_class" ]] || continue
        basename "$desktop_file"
        return 0
    done

    return 1
}

save_session() {
    local clients
    local active_workspace
    local client
    local pid
    local workspace
    local window_class
    local executable
    local desktop_id
    local record
    local args_json
    local temporary_file
    local -a argv

    require_commands || return 1
    clients="$(hyprctl -j clients 2>/dev/null)" || return 1
    active_workspace="$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.name // empty')" || return 1
    mkdir -p "$STATE_DIR"
    chmod 700 "$STATE_DIR"
    temporary_file="$(mktemp "$STATE_DIR/workspace-session.XXXXXX")" || return 1

    while IFS= read -r client; do
        pid="$(jq -r '.pid' <<<"$client")"
        workspace="$(jq -r '.workspace.name' <<<"$client")"
        window_class="$(jq -r '.initialClass // .class // empty' <<<"$client")"
        [[ "$pid" =~ ^[1-9][0-9]*$ ]] || continue
        [[ "$workspace" =~ ^[1-9][0-9]*$ ]] || continue

        executable="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
        [[ -n "$executable" && -x "$executable" ]] || continue

        desktop_id="$(desktop_entry_for_class "$window_class" || true)"
        if [[ "$(basename "$executable")" == 'ghostty' ]]; then
            mapfile -d '' -t argv <"/proc/$pid/cmdline" || continue
            [[ "$(basename "${argv[0]:-}")" == "$(basename "$executable")" ]] || continue
            argv[0]="$executable"
            args_json="$(printf '%s\0' "${argv[@]}" | jq -Rs 'split("\u0000")[:-1]')" || continue
            record="$(jq -cn \
                --arg workspace "$workspace" \
                --arg executable "$executable" \
                --arg desktop_id "$desktop_id" \
                --argjson argv "$args_json" \
                '{workspace: $workspace, executable: $executable, desktop_id: $desktop_id, argv: $argv}')"
        else
            record="$(jq -cn \
                --arg workspace "$workspace" \
                --arg executable "$executable" \
                --arg desktop_id "$desktop_id" \
                '{workspace: $workspace, executable: $executable, desktop_id: $desktop_id}')"
        fi
        printf '%s\n' "$record"
    done < <(jq -c '.[] | select(.mapped and .workspace.id > 0)' <<<"$clients") |
        jq -s --argjson version "$STATE_VERSION" --arg active_workspace "$active_workspace" \
            '{version: $version, active_workspace: $active_workspace, clients: unique_by(.)}' \
            >"$temporary_file" || {
        rm -f "$temporary_file"
        return 1
    }

    chmod 600 "$temporary_file"
    mv -f "$temporary_file" "$STATE_FILE"
    log "saved $(jq '.clients | length' "$STATE_FILE") clients"
}

desktop_file_for_id() {
    local desktop_id=$1
    local desktop_file

    [[ "$desktop_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*\.desktop$ ]] || return 1
    for desktop_file in \
        "$HOME/.local/share/applications/$desktop_id" \
        "/usr/local/share/applications/$desktop_id" \
        "/usr/share/applications/$desktop_id"; do
        [[ -r "$desktop_file" ]] && printf '%s\n' "$desktop_file" && return 0
    done

    return 1
}

launch_on_workspace() {
    local workspace=$1
    local command=$2
    local workspace_rule
    local expression
    local output

    [[ "$workspace" =~ ^[1-9][0-9]*$ ]] || return 1
    workspace_rule="$(lua_string "$workspace silent")"
    expression="hl.exec_cmd($(lua_string "$command"), { workspace = $workspace_rule })"
    if [[ ${WORKSPACE_SESSION_DRY_RUN:-} == 1 ]]; then
        printf '%s\n' "$expression"
        return 0
    fi

    if output="$(hyprctl eval "$expression" 2>&1)"; then
        log "queued workspace $workspace: $command"
        return 0
    fi

    log "failed workspace $workspace: $output"
    return 1
}

lua_string() {
    local value=$1
    local delimiter='='

    while [[ "$value" == *"]$delimiter]"* ]]; do
        delimiter+='='
    done
    printf '[%s[%s]%s]' "$delimiter" "$value" "$delimiter"
}

managed_command() {
    local command=$1

    if use_uwsm; then
        printf 'uwsm app -- %s\n' "$command"
    else
        printf '%s\n' "$command"
    fi
}

focus_workspace() {
    local workspace=$1

    [[ "$workspace" =~ ^[1-9][0-9]*$ ]] || return 1
    if [[ ${WORKSPACE_SESSION_DRY_RUN:-} == 1 ]]; then
        printf 'hl.dispatch(hl.dsp.focus({ workspace = %s }))\n' "$workspace"
        return 0
    fi

    hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = $workspace }))" >/dev/null 2>&1
}

visit_restored_workspaces() {
    local active_workspace=$1
    shift
    local workspace
    local -A visited=()

    if [[ ${WORKSPACE_SESSION_DRY_RUN:-} == 1 ]]; then
        for workspace in "$@"; do
            [[ "$workspace" == "$active_workspace" || -n ${visited[$workspace]:-} ]] && continue
            visited[$workspace]=1
            focus_workspace "$workspace"
        done
        focus_workspace "$active_workspace"
        return 0
    fi

    # Electron and browser activation requests can arrive after the first mapped
    # surface. Wait before visiting every restored workspace to clear urgency.
    sleep 3
    for workspace in "$@"; do
        [[ "$workspace" == "$active_workspace" || -n ${visited[$workspace]:-} ]] && continue
        visited[$workspace]=1
        focus_workspace "$workspace" || continue
        sleep 1
    done
    focus_workspace "$active_workspace" || true
}

desktop_command() {
    local desktop_id=$1
    local desktop_file
    local command

    desktop_file="$(desktop_file_for_id "$desktop_id")" || return 1
    command="$(awk -F= '$1 == "Exec" { print substr($0, index($0, "=") + 1); exit }' "$desktop_file")"
    [[ -n "$command" ]] || return 1

    # No document or URL state is restored, so discard Desktop Entry field codes.
    command="${command//%%/%}"
    command="${command//%[fFuUdDnNickvm]/}"
    command="${command#"${command%%[![:space:]]*}"}"
    command="${command%"${command##*[![:space:]]}"}"
    [[ -n "$command" ]] || return 1
    managed_command "$command"
}

shell_command_from_argv() {
    local argv_json=$1
    local argument
    local command=''

    while IFS= read -r argument; do
        printf -v argument '%q' "$argument"
        command+="${command:+ }$argument"
    done < <(jq -r '.[]' <<<"$argv_json")
    printf '%s\n' "$command"
}

tmux_home_command() {
    local executable=$1
    local command

    printf -v command '%q ' "$executable" -e tmux new-session -A -s home
    command="${command% }"
    managed_command "$command"
}

restore_default_session() {
    local herdr_command="sh -c 'command -v herdr >/dev/null 2>&1 || exit 0; exec ghostty -e herdr'"

    initialize_tmux_sessions
    launch_on_workspace 1 "$(tmux_home_command "$(command -v ghostty)")"
    launch_on_workspace 2 "$(managed_command 'zen-browser')"
    launch_on_workspace 3 "$(managed_command "$herdr_command")"
    visit_restored_workspaces 1 1 2 3
}

initialize_tmux_sessions() {
    local script="$HOME/.local/bin/tmux-init.sh"

    [[ -x "$script" ]] || return 0
    if [[ ${WORKSPACE_SESSION_DRY_RUN:-} == 1 ]]; then
        printf '%q\n' "$script"
        return 0
    fi

    "$script" || log 'tmux session initialization failed'
}

restore_session() {
    local client
    local workspace
    local executable
    local desktop_id
    local argv
    local command
    local active_workspace
    local -a restored_workspaces=()

    require_commands || return 1
    if [[ ! -r "$STATE_FILE" ]]; then
        log 'no saved session; restoring defaults'
        restore_default_session
        return 0
    fi

    jq -e --argjson version "$STATE_VERSION" '
        .version == $version and (.clients | type == "array")
    ' "$STATE_FILE" >/dev/null 2>&1 || {
        log 'invalid saved session; restoring defaults'
        restore_default_session
        return 0
    }

    active_workspace="$(jq -r '.active_workspace // empty' "$STATE_FILE")"
    log "restoring $(jq '.clients | length' "$STATE_FILE") clients"
    initialize_tmux_sessions
    while IFS= read -r client; do
        workspace="$(jq -r '.workspace' <<<"$client")"
        executable="$(jq -r '.executable' <<<"$client")"
        desktop_id="$(jq -r '.desktop_id // empty' <<<"$client")"
        [[ "$workspace" =~ ^[1-9][0-9]*$ && -x "$executable" ]] || continue

        if jq -e '.argv? | type == "array" and length > 0' <<<"$client" >/dev/null; then
            argv="$(jq -c '.argv' <<<"$client")"
            [[ "$(jq -r '.[0]' <<<"$argv")" == "$executable" ]] || continue
            if [[ "$(basename "$executable")" == 'ghostty' && "$(jq 'length' <<<"$argv")" == 1 ]]; then
                command="$(tmux_home_command "$executable")"
            else
                command="$(managed_command "$(shell_command_from_argv "$argv")")"
            fi
        elif [[ -n "$desktop_id" ]] && desktop_file_for_id "$desktop_id" >/dev/null; then
            command="$(desktop_command "$desktop_id")"
        else
            command="$(managed_command "$(printf '%q' "$executable")")"
        fi
        launch_on_workspace "$workspace" "$command"
        restored_workspaces+=("$workspace")
    done < <(jq -c '.clients[]' "$STATE_FILE")

    if [[ "$active_workspace" =~ ^[1-9][0-9]*$ ]]; then
        visit_restored_workspaces "$active_workspace" "${restored_workspaces[@]}"
    fi
}

case "${1:-}" in
save)
    save_session
    ;;
restore)
    restore_session
    ;;
plan)
    WORKSPACE_SESSION_DRY_RUN=1 restore_session
    ;;
reboot)
    save_session || exit $?
    exec systemctl reboot
    ;;
poweroff)
    save_session || exit $?
    exec systemctl poweroff
    ;;
*)
    printf 'usage: %s {save|restore|plan|reboot|poweroff}\n' "$0" >&2
    exit 2
    ;;
esac
