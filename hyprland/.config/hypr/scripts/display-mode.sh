#!/usr/bin/env bash

# Switch the laptop's HDMI output between mirror, extended, and disabled modes.

set -u -o pipefail

readonly INTERNAL_OUTPUT=eDP-1
readonly HDMI_OUTPUT=HDMI-A-1
readonly AUDIO_POLICY="$HOME/.config/hypr/scripts/audio-output-policy.sh"
readonly STATE_FILE="${XDG_RUNTIME_DIR:-}/hypr-display-mode.json"

command -v fuzzel >/dev/null 2>&1 || exit 0
command -v hyprctl >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0
[[ -n ${XDG_RUNTIME_DIR:-} ]] || exit 0

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send '顯示器' "$1"
}

monitors() {
    hyprctl -j monitors all 2>/dev/null
}

workspaces() {
    hyprctl -j workspaces 2>/dev/null
}

has_monitor() {
    monitors | jq -e --arg output "$1" 'any(.[]; .name == $output)' >/dev/null 2>&1
}

wait_for_hdmi() {
    for _ in {1..20}; do
        if monitors | jq -e --arg output "$HDMI_OUTPUT" '
            any(.[]; .name == $output and .disabled == false)
        ' >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done

    return 1
}

apply_lua() {
    hyprctl eval "$1" >/dev/null 2>&1
}

is_mirror() {
    monitors | jq -e --arg output "$HDMI_OUTPUT" '
        any(.[]; .name == $output and .mirrorOf != "none")
    ' >/dev/null 2>&1
}

hdmi_workspaces() {
    workspaces | jq -r --arg output "$HDMI_OUTPUT" '
        [.[] | select(.monitor == $output and .id > 0) | .id] | unique | sort | .[]
    '
}

record_hdmi_workspaces() {
    local state
    local temporary

    state=$(workspaces | jq --arg output "$HDMI_OUTPUT" '
        [.[] | select(.monitor == $output and .id > 0) | .id] | unique | sort
    ') || return

    [[ $state != '[]' ]] || return

    temporary=$(mktemp "$XDG_RUNTIME_DIR/hypr-display-mode.XXXXXX") || return
    printf '%s\n' "$state" >"$temporary"
    mv "$temporary" "$STATE_FILE"
}

move_workspace_to_internal() {
    local workspace=$1

    apply_lua "hl.dispatch(hl.dsp.workspace.move({ workspace = $workspace, monitor = '$INTERNAL_OUTPUT' }))"
}

move_workspace_to_hdmi() {
    local workspace=$1

    apply_lua "hl.dispatch(hl.dsp.workspace.move({ workspace = $workspace, monitor = '$HDMI_OUTPUT' }))"
}

relocate_hdmi_workspaces() {
    local workspace

    while read -r workspace; do
        [[ $workspace =~ ^[1-9][0-9]*$ ]] || continue
        move_workspace_to_internal "$workspace" || return
    done < <(hdmi_workspaces)
}

restore_hdmi_workspaces() {
    local workspace

    [[ -r $STATE_FILE ]] || return
    while read -r workspace; do
        [[ $workspace =~ ^[1-9][0-9]*$ ]] || continue
        move_workspace_to_hdmi "$workspace" || return
    done < <(jq -r '.[]' "$STATE_FILE" 2>/dev/null)
}

refresh_audio() {
    [[ -x $AUDIO_POLICY ]] && "$AUDIO_POLICY" --apply
}

mirror() {
    record_hdmi_workspaces
    relocate_hdmi_workspaces || return
    apply_lua "hl.monitor({ output = '$HDMI_OUTPUT', disabled = false, mode = 'preferred', position = '0x0', scale = 1, mirror = '$INTERNAL_OUTPUT' })" || return
    relocate_hdmi_workspaces || return
    refresh_audio
    notify 'HDMI 已鏡像內建螢幕'
}

extend() {
    apply_lua "hl.monitor({ output = '$HDMI_OUTPUT', disabled = false, mode = 'preferred', position = 'auto-right', scale = 1, mirror = '' })" || return
    wait_for_hdmi || return
    restore_hdmi_workspaces || return
    refresh_audio
}

extend_current_workspace() {
    local workspace

    workspace=$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.id') || return
    [[ $workspace =~ ^[1-9][0-9]*$ ]] || return

    extend || return
    move_workspace_to_hdmi "$workspace" || return
    record_hdmi_workspaces
    notify "HDMI 已延伸並移動工作區 $workspace"
}

move_workspace() {
    local workspace=$1

    [[ $workspace =~ ^[1-9][0-9]*$ ]] || return
    extend || return
    move_workspace_to_hdmi "$workspace" || return
    record_hdmi_workspaces
    notify "工作區 $workspace 已移至 HDMI"
}

internal_only() {
    record_hdmi_workspaces
    relocate_hdmi_workspaces || return
    apply_lua "hl.monitor({ output = '$HDMI_OUTPUT', disabled = true, mirror = '' })" || return
    refresh_audio
    notify '已只使用內建螢幕'
}

has_monitor "$INTERNAL_OUTPUT" || {
    notify '找不到內建螢幕'
    exit 1
}

has_monitor "$HDMI_OUTPUT" || {
    notify '找不到 HDMI 螢幕'
    exit 1
}

if [[ ${1:-} == --repair-mirror ]]; then
    if is_mirror; then
        [[ -r $STATE_FILE ]] || record_hdmi_workspaces
        relocate_hdmi_workspaces
    fi
    exit 0
fi

selection=$({
    printf '%s\n' '鏡像內建螢幕' '延伸並移動目前工作區' '只使用內建螢幕'
    monitors | jq -r '
        map(select(.activeWorkspace.id > 0)) |
        map(.activeWorkspace.id) |
        unique |
        sort |
        .[] | "移動工作區 \(.) 到 HDMI"
    '
} | fuzzel --dmenu --prompt '顯示器 > ') || exit 0

case $selection in
'鏡像內建螢幕')
    mirror
    ;;
'延伸並移動目前工作區')
    extend_current_workspace
    ;;
'只使用內建螢幕')
    internal_only
    ;;
'移動工作區 '*' 到 HDMI')
    workspace=${selection#移動工作區 }
    workspace=${workspace% 到 HDMI}
    move_workspace "$workspace"
    ;;
esac
