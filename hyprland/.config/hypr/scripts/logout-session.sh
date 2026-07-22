#!/usr/bin/env bash

# Quietly terminate the active graphical login session.
# Do not rely on XDG_SESSION_ID because persistent tmux servers may retain
# an obsolete session ID.

set -u

user_uid="$(id -u)"

find_graphical_session() {
    local session_id
    local session_uid
    local active
    local type
    local class

    while read -r session_id session_uid _; do
        [[ "$session_uid" == "$user_uid" ]] || continue

        active="$(
            loginctl show-session "$session_id" \
                --property=Active \
                --value 2>/dev/null ||
                true
        )"

        type="$(
            loginctl show-session "$session_id" \
                --property=Type \
                --value 2>/dev/null ||
                true
        )"

        class="$(
            loginctl show-session "$session_id" \
                --property=Class \
                --value 2>/dev/null ||
                true
        )"

        if [[ "$active" == "yes" ]] &&
            [[ "$class" == "user" ]] &&
            [[ "$type" == "wayland" || "$type" == "x11" ]]; then
            printf '%s\n' "$session_id"
            return 0
        fi
    done < <(
        loginctl list-sessions \
            --no-legend \
            --no-pager 2>/dev/null
    )

    return 1
}

graphical_session="$(find_graphical_session || true)"

if [[ -n "$graphical_session" ]]; then
    if loginctl terminate-session "$graphical_session" \
        >/dev/null 2>&1; then
        exit 0
    fi
fi

if command -v uwsm >/dev/null 2>&1 &&
    systemctl --user is-active \
        --quiet 'wayland-session@*.target'; then
    if uwsm stop >/dev/null 2>&1; then
        exit 0
    fi
fi

if command -v hyprshutdown >/dev/null 2>&1; then
    exec hyprshutdown >/dev/null 2>&1
fi

exec hyprctl dispatch exit >/dev/null 2>&1
