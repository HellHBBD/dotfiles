-- Session startup.
--
-- Every optional program is guarded so a missing package does not prevent
-- Hyprland from starting. When UWSM owns the session, long-running processes
-- are placed in its background slice for ordered shutdown.

local function start_once(process_match, command)
    local executable = command:match("^%S+")

    hl.exec_cmd(string.format([[
if command -v %q >/dev/null 2>&1 && ! pgrep -f %q >/dev/null 2>&1; then
    if command -v uwsm >/dev/null 2>&1 &&
        systemctl --user is-active --quiet 'wayland-wm@*.service'; then
        exec uwsm app -s b -- %s
    else
        exec %s
    fi
fi
]], executable, process_match, command, command))
end

hl.on("hyprland.start", function()
    local is_uwsm_session = [[
command -v uwsm >/dev/null 2>&1 &&
    systemctl --user is-active --quiet 'wayland-wm@*.service'
]]

    -- UWSM already synchronizes the activation environment.
    hl.exec_cmd(string.format([[
if ! (%s); then
    dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY \
        HYPRLAND_INSTANCE_SIGNATURE \
        XDG_CURRENT_DESKTOP

    systemctl --user import-environment \
        WAYLAND_DISPLAY \
        HYPRLAND_INSTANCE_SIGNATURE \
        XDG_CURRENT_DESKTOP
fi
]], is_uwsm_session))

    -- Core desktop components.
    start_once("(^|/)waybar($| )", "waybar")
    start_once("(^|/)swaync($| )", "swaync")
    start_once("(^|/)hypridle($| )", "hypridle")
    start_once("(^|/)hyprpaper($| )", "hyprpaper")

    -- Prefer Hyprland's polkit agent, then fall back to KDE's agent.
    hl.exec_cmd([[
if command -v hyprpolkitagent >/dev/null 2>&1; then
    if ! pgrep -f '(^|/)hyprpolkitagent($| )' >/dev/null 2>&1; then
        exec hyprpolkitagent
    fi
elif [ -x /usr/lib/polkit-kde-authentication-agent-1 ] &&
    ! pgrep -f 'polkit-kde-authentication-agent-1' >/dev/null 2>&1; then
    exec /usr/lib/polkit-kde-authentication-agent-1
fi
]])
end)
