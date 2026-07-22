-- Session startup.
--
-- Direct Hyprland sessions import Wayland variables into systemd and D-Bus.
-- UWSM sessions already manage that environment, so their desktop services are
-- launched through `uwsm app --` for ordered shutdown.

local function start_once(binary, process_pattern, command)
	command = command or binary

	hl.exec_cmd(string.format(
		[[
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
]],
		binary,
		process_pattern,
		command,
		command
	))
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

	-- Desktop services are owned by systemd user services.
	hl.exec_cmd([[
systemctl --user reset-failed \
    swaync.service \
    hyprpolkitagent.service \
    cliphist.service \
    >/dev/null 2>&1 || true

systemctl --user start \
    swaync.service \
    hyprpolkitagent.service \
    cliphist.service \
    >/dev/null 2>&1 || true
]])

	start_once("hypridle", "(^|/)hypridle($| )", "hypridle")
	start_once("hyprpaper", "(^|/)hyprpaper($| )", "hyprpaper")

	-- Initialize the default tmux workspace once.
	hl.exec_cmd([[
if ! command -v tmux >/dev/null 2>&1; then
    exit 0
fi

script="$HOME/shs/tmux-init.sh"

if [ ! -x "$script" ]; then
    exit 0
fi

# Do not recreate sessions when a tmux server already has sessions.
if tmux list-sessions >/dev/null 2>&1; then
    exit 0
fi

exec "$script" >/dev/null 2>&1
]])
end)
