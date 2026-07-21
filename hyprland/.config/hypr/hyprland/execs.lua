-- Session startup.
--
-- Direct Hyprland sessions import Wayland variables into systemd and D-Bus.
-- UWSM sessions already manage that environment, so their desktop services are
-- launched through `uwsm app --` for ordered shutdown.

local function start_once(binary, process_pattern, command)
    command = command or binary

    hl.exec_cmd(string.format([[
if ! command -v %s >/dev/null 2>&1; then
    exit 0
fi

if pgrep -f -- '%s' >/dev/null 2>&1; then
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- %s
else
    exec %s
fi
]], binary, process_pattern, command, command))
end

hl.on("hyprland.start", function()
    -- UWSM already manages the graphical-session activation environment.
    hl.exec_cmd([[
if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exit 0
fi

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY \
        HYPRLAND_INSTANCE_SIGNATURE \
        XDG_CURRENT_DESKTOP \
        XDG_SESSION_DESKTOP \
        XDG_SESSION_TYPE
fi

systemctl --user import-environment \
    WAYLAND_DISPLAY \
    HYPRLAND_INSTANCE_SIGNATURE \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    XDG_SESSION_TYPE
]])

    -- Core desktop components.
    start_once("waybar", "(^|/)waybar($| )", "waybar")
    start_once("swaync", "(^|/)swaync($| )", "swaync")
    start_once("hypridle", "(^|/)hypridle($| )", "hypridle")
    start_once("hyprpaper", "(^|/)hyprpaper($| )", "hyprpaper")

    -- Prefer Hyprland's polkit agent, then fall back to KDE's agent.
    hl.exec_cmd([[
if pgrep -f -- '(^|/)(hyprpolkitagent|polkit-kde-authentication-agent-1)($| )' \
    >/dev/null 2>&1; then
    exit 0
fi

agent=""

if command -v hyprpolkitagent >/dev/null 2>&1; then
    agent="hyprpolkitagent"
elif [ -x /usr/lib/polkit-kde-authentication-agent-1 ]; then
    agent="/usr/lib/polkit-kde-authentication-agent-1"
fi

if [ -z "$agent" ]; then
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- "$agent"
else
    exec "$agent"
fi
]])
end)
