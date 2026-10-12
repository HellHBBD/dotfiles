#!/usr/bin/env bash

# Choose connected outputs at runtime, including outputs disabled by this menu.
set -u -o pipefail

readonly AUDIO_POLICY="$HOME/.config/hypr/scripts/audio-output-policy.sh"
readonly STATE_FILE="${XDG_RUNTIME_DIR:-}/hypr-display-mode.json"
SOURCE_OUTPUT=''
TARGET_OUTPUT=''
MONITORS='[]'

for dependency in hyprctl jq flock; do
    command -v "$dependency" >/dev/null 2>&1 || exit 1
done
[[ -n ${XDG_RUNTIME_DIR:-} ]] || exit 1

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send '顯示器' "$1"
    fi
}

refresh_monitors() {
    MONITORS=$(hyprctl -j monitors all 2>/dev/null) &&
        jq -e 'type == "array" and all(.[]; (.name | type == "string"))' <<<"$MONITORS" >/dev/null
}

valid_output() {
    # Connector identifiers, not descriptions, are interpolated into Lua.
    [[ $1 =~ ^[a-zA-Z0-9_.:-]+$ ]]
}

source_available() {
    jq -e --arg source "$SOURCE_OUTPUT" '
        any(.[]; .name == $source and .disabled == false and
            ((.mirrorOf // "none") == "none" or .mirrorOf == ""))
    ' <<<"$MONITORS" >/dev/null
}

check_pair() {
    refresh_monitors || return 1
    if ! { valid_output "$SOURCE_OUTPUT" && valid_output "$TARGET_OUTPUT" &&
        [[ $SOURCE_OUTPUT != "$TARGET_OUTPUT" ]] && source_available &&
        jq -e --arg target "$TARGET_OUTPUT" 'any(.[]; .name == $target)' <<<"$MONITORS" >/dev/null; }; then
        notify '螢幕連接狀態已改變，請重新選擇來源與目標'
        return 1
    fi
}

check_target_change() {
    check_pair || return
    if jq -e --arg target "$TARGET_OUTPUT" '
        any(.[]; .disabled == false and .mirrorOf == $target)
    ' <<<"$MONITORS" >/dev/null; then
        notify '目標螢幕正供其他螢幕鏡像，請先解除那些鏡像'
        return 1
    fi
}

lock_state() {
    exec {state_lock}>"$XDG_RUNTIME_DIR/hypr-display-mode.lock" || return
    flock -w 3 "$state_lock"
}

load_state() {
    if [[ -r $STATE_FILE ]]; then
        jq '
            if type == "array" then
                {version: 2, outputs: {"HDMI-A-1": {source: "eDP-1", workspaces: .}}}
            elif .version == 2 and (.outputs | type == "object") then .
            else {version: 2, outputs: {}} end
        ' "$STATE_FILE" 2>/dev/null && return
    fi
    printf '%s\n' '{"version":2,"outputs":{}}'
}

target_settings() {
    local state
    state=$(load_state) || return
    jq -c --arg target "$TARGET_OUTPUT" --argjson state "$state" '
        .[] | select(.name == $target) | . as $m |
        if (.disabled == true or ((.mirrorOf // "none") != "none" and .mirrorOf != ""))
            and ($state.outputs[$target].settings | type == "object") then
            $state.outputs[$target].settings
        else
            {mode: ([.availableModes[]? |
                try capture("^(?<w>[0-9]+)x(?<h>[0-9]+)@(?<hz>[0-9.]+)Hz$") |
                select((((.w | tonumber) == $m.width and (.h | tonumber) == $m.height) or
                    ((.w | tonumber) == $m.height and (.h | tonumber) == $m.width)) and
                    (((.hz | tonumber) - $m.refreshRate) | fabs) < 0.1) |
                "\(.w)x\(.h)@\(.hz)"][0] // "preferred"),
             scale: (if (.scale // 0) > 0 then .scale else "auto" end),
             transform: (.transform // 0),
             position: "\(.x // 0)x\(.y // 0)"}
        end
    ' <<<"$MONITORS"
}

valid_settings() {
    jq -e '
        (.mode | type == "string") and (.position | type == "string") and
        ((.scale | type == "number" and . > 0) or .scale == "auto") and
        (.transform | type == "number" and . >= 0 and . <= 7 and . == floor)
    ' <<<"$1" >/dev/null
}

remember_target() {
    local workspaces settings state temporary
    workspaces=$(hyprctl -j workspaces 2>/dev/null | jq -c --arg target "$TARGET_OUTPUT" '
        [.[] | select(.monitor == $target and .id > 0) | .id] | unique | sort
    ') || return
    settings=$(target_settings) || return
    valid_settings "$settings" || return 1
    state=$(load_state) || return
    state=$(jq --arg target "$TARGET_OUTPUT" --arg source "$SOURCE_OUTPUT" \
        --argjson workspaces "$workspaces" --argjson settings "$settings" '
        .outputs[$target] = {
            source: $source,
            settings: $settings,
            workspaces: (if ($workspaces | length) > 0 then $workspaces
                elif .outputs[$target].source == $source then (.outputs[$target].workspaces // [])
                else [] end)
        }
    ' <<<"$state") || return
    temporary=$(mktemp "$XDG_RUNTIME_DIR/hypr-display-mode.XXXXXX") || return
    if printf '%s\n' "$state" >"$temporary" && mv "$temporary" "$STATE_FILE"; then
        return 0
    fi
    rm -f "$temporary"
    return 1
}

apply_lua() {
    if ! hyprctl eval "$1" >/dev/null 2>&1; then
        notify '無法套用螢幕或工作區設定'
        return 1
    fi
}

move_workspaces() {
    local output=$1 ids=$2 workspace code='' quoted
    [[ -n $ids ]] || return 0
    check_pair || return
    jq -e --arg output "$output" 'any(.[]; .name == $output and .disabled == false)' \
        <<<"$MONITORS" >/dev/null || return 1
    quoted=$(jq -Rn --arg output "$output" '$output') || return
    while read -r workspace; do
        [[ $workspace =~ ^[1-9][0-9]*$ ]] || return 1
        code+="hl.dispatch(hl.dsp.workspace.move({ workspace = $workspace, monitor = $quoted })); "
    done <<<"$ids"
    apply_lua "$code"
}

relocate_target_workspaces() {
    local ids
    ids=$(hyprctl -j workspaces 2>/dev/null | jq -r --arg target "$TARGET_OUTPUT" '
        [.[] | select(.monitor == $target and .id > 0) | .id] | unique | sort | .[]
    ') || return
    move_workspaces "$SOURCE_OUTPUT" "$ids"
}

restore_target_workspaces() {
    local state workspaces ids
    state=$(load_state) || return
    workspaces=$(hyprctl -j workspaces 2>/dev/null) || return
    ids=$(jq -r --arg target "$TARGET_OUTPUT" --arg source "$SOURCE_OUTPUT" \
        --argjson workspaces "$workspaces" '
        .outputs[$target] | select(.source == $source) |
        .workspaces[]? | . as $id |
        select(type == "number" and . > 0 and . == floor) |
        select(any($workspaces[]; .id == $id and .monitor == $source))
    ' <<<"$state") || return
    move_workspaces "$TARGET_OUTPUT" "$ids"
}

configure_target() {
    local mirror=$1 settings mode scale transform position output source
    check_pair || return
    # A mirror source cannot itself become a mirror or disappear.
    if [[ -n $mirror || $2 == true ]] && jq -e --arg target "$TARGET_OUTPUT" '
        any(.[]; .disabled == false and .mirrorOf == $target)
    ' <<<"$MONITORS" >/dev/null; then
        notify '目標螢幕正供其他螢幕鏡像，請先解除那些鏡像'
        return 1
    fi
    settings=$(target_settings) || return
    valid_settings "$settings" || return 1
    mode=$(jq -r '.mode | @json' <<<"$settings") || return
    scale=$(jq -r '.scale | @json' <<<"$settings") || return
    transform=$(jq -r '.transform' <<<"$settings") || return
    position=$(jq -r '.position | @json' <<<"$settings") || return
    if [[ -n $mirror ]]; then
        position=$(jq -r --arg source "$SOURCE_OUTPUT" '
            .[] | select(.name == $source) | "\(.x)x\(.y)" | @json
        ' <<<"$MONITORS") || return
    elif jq -e --arg target "$TARGET_OUTPUT" '
        any(.[]; .name == $target and (.disabled == true or
            ((.mirrorOf // "none") != "none" and .mirrorOf != "")))
    ' <<<"$MONITORS" >/dev/null; then
        position='"auto-right"'
    fi
    output=$(jq -Rn --arg output "$TARGET_OUTPUT" '$output') || return
    source=$(jq -Rn --arg source "$mirror" '$source') || return
    apply_lua "hl.monitor({ output = $output, disabled = $2, mode = $mode, position = $position, scale = $scale, transform = $transform, mirror = $source })"
}

wait_for_target() {
    local disabled=$1 mirror=$2
    for _ in {1..20}; do
        check_pair || return
        if jq -e --arg target "$TARGET_OUTPUT" --arg mirror "$mirror" --argjson disabled "$disabled" '
            any(.[]; .name == $target and .disabled == $disabled and
                (if $disabled then true elif $mirror == "" then
                    ((.mirrorOf // "none") == "none" or .mirrorOf == "")
                 else .mirrorOf == $mirror end))
        ' <<<"$MONITORS" >/dev/null; then
            return 0
        fi
        sleep 0.1
    done
    notify '螢幕未在預期時間內完成切換'
    return 1
}

refresh_audio() {
    # The existing audio policy is specific to the laptop's NVIDIA HDMI port.
    # Other connector pairs must not invoke that machine-specific policy.
    if [[ ($SOURCE_OUTPUT == eDP-1 && $TARGET_OUTPUT == HDMI-A-1) ||
        ($SOURCE_OUTPUT == HDMI-A-1 && $TARGET_OUTPUT == eDP-1) ]]; then
        if [[ -x $AUDIO_POLICY ]]; then
            "$AUDIO_POLICY" --apply
        fi
    fi
}

mirror() {
    check_target_change && remember_target && relocate_target_workspaces &&
        configure_target "$SOURCE_OUTPUT" false && wait_for_target false "$SOURCE_OUTPUT" &&
        relocate_target_workspaces || return 1
    refresh_audio
    notify "$TARGET_OUTPUT 已鏡像 $SOURCE_OUTPUT"
}

extend() {
    check_pair && configure_target '' false && wait_for_target false '' &&
        restore_target_workspaces || return 1
    refresh_audio
}

extend_workspace() {
    local workspace=$1
    [[ $workspace =~ ^[1-9][0-9]*$ ]] || {
        notify '請先選擇一般工作區，再移動到目標螢幕'
        return 1
    }
    hyprctl -j workspaces 2>/dev/null | jq -e --argjson workspace "$workspace" \
        'any(.[]; .id == $workspace)' >/dev/null || return 1
    extend && move_workspaces "$TARGET_OUTPUT" "$workspace" && remember_target || return 1
    notify "工作區 $workspace 已移至 $TARGET_OUTPUT"
}

disable_target() {
    # check_pair requires an enabled independent source immediately before mutation.
    check_target_change && remember_target && relocate_target_workspaces &&
        configure_target '' true && wait_for_target true '' || return 1
    refresh_audio
    notify "已停用 $TARGET_OUTPUT，保留 $SOURCE_OUTPUT"
}

choose_output() {
    local candidates=$1 prompt=$2 selection
    if [[ $(jq 'length' <<<"$candidates") == 1 ]]; then
        jq -r '.[0].name' <<<"$candidates"
        return
    fi
    selection=$(jq -r '.[] |
        "\(.name) — \((.description // .model // "") | gsub("[\\r\\n\\t]"; " "))" +
        (if .disabled then "（停用）" else "" end)
    ' <<<"$candidates" | fuzzel --dmenu --prompt "$prompt") || return 1
    selection=${selection%% *}
    jq -er --arg name "$selection" '.[] | select(.name == $name) | .name' <<<"$candidates"
}

repair_mirrors() {
    local targets target source state
    lock_state || return 0
    refresh_monitors || return 1
    targets=$(jq -r '.[] | select(.disabled == false and
        (.mirrorOf // "none") != "none" and .mirrorOf != "") | .name' <<<"$MONITORS") || return
    [[ -n $targets ]] || return 0
    while read -r target; do
        refresh_monitors || return 1
        source=$(jq -r --arg target "$target" '.[] | select(.name == $target) | .mirrorOf // "none"' \
            <<<"$MONITORS") || return
        [[ -n $source && $source != none ]] || continue
        SOURCE_OUTPUT=$source
        TARGET_OUTPUT=$target
        source_available || continue
        check_pair || continue
        state=$(load_state) || return
        if ! jq -e --arg target "$target" --arg source "$source" \
            '.outputs[$target].source == $source' <<<"$state" >/dev/null; then
            remember_target || return
        fi
        relocate_target_workspaces || return
    done <<<"$targets"
}

if [[ ${1:-} == --repair-mirror ]]; then
    repair_mirrors
    exit $?
fi
[[ $# == 0 ]] || exit 1
command -v fuzzel >/dev/null 2>&1 || exit 1
refresh_monitors || {
    notify '無法讀取螢幕狀態'
    exit 1
}

SOURCE_OUTPUT=$(jq -r '
    [.[] | select(.disabled == false and
        ((.mirrorOf // "none") == "none" or .mirrorOf == ""))] |
    sort_by(.id) |
    (map(select(.name | test("^(eDP|LVDS|DSI)-")))[0] //
     map(select(.focused == true))[0] // .[0]) | .name // empty
' <<<"$MONITORS") || exit 1
[[ -n $SOURCE_OUTPUT ]] || {
    notify '找不到啟用中的來源螢幕'
    exit 1
}

while true; do
    candidates=$(jq -c --arg source "$SOURCE_OUTPUT" '[.[] | select(.name != $source)] | sort_by(.id)' \
        <<<"$MONITORS") || exit 1
    [[ $(jq 'length' <<<"$candidates") != 0 ]] || {
        notify '目前只有一台螢幕，無需切換'
        exit 0
    }
    TARGET_OUTPUT=$(choose_output "$candidates" '目標螢幕 > ') || exit 0
    selection=$({
        printf '%s\n' "鏡像 $SOURCE_OUTPUT 到 $TARGET_OUTPUT" '延伸顯示' \
            '延伸並移動目前工作區' "停用 $TARGET_OUTPUT（保留 $SOURCE_OUTPUT）" '更換來源螢幕'
        hyprctl -j workspaces 2>/dev/null | jq -r --arg target "$TARGET_OUTPUT" '
            [.[] | select(.id > 0) | .id] | unique | sort | .[] |
            "移動工作區 \(.) 到 \($target)"
        '
    } | fuzzel --dmenu --prompt "$SOURCE_OUTPUT → $TARGET_OUTPUT > ") || exit 0
    if [[ $selection == '更換來源螢幕' ]]; then
        refresh_monitors || exit 1
        candidates=$(jq -c '[.[] | select(.disabled == false and
            ((.mirrorOf // "none") == "none" or .mirrorOf == ""))] | sort_by(.id)' <<<"$MONITORS") || exit 1
        [[ $(jq 'length' <<<"$candidates") != 0 ]] || exit 1
        SOURCE_OUTPUT=$(choose_output "$candidates" '來源螢幕 > ') || exit 0
        continue
    fi
    break
done

lock_state || exit 1
case $selection in
"鏡像 $SOURCE_OUTPUT 到 $TARGET_OUTPUT") mirror ;;
'延伸顯示') extend && notify "$TARGET_OUTPUT 已延伸顯示" ;;
'延伸並移動目前工作區')
    workspace=$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.id') || exit 1
    extend_workspace "$workspace"
    ;;
"停用 $TARGET_OUTPUT（保留 $SOURCE_OUTPUT）") disable_target ;;
"移動工作區 "*" 到 $TARGET_OUTPUT")
    workspace=${selection#移動工作區 }
    workspace=${workspace% 到 "$TARGET_OUTPUT"}
    extend_workspace "$workspace"
    ;;
*) exit 0 ;;
esac
