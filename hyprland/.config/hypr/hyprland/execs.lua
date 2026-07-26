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

local function start_on_workspace(binary, workspace, launch_command, rules)
	launch_command = launch_command or binary
	rules = rules or {}

	local command = string.format(
		[[
if ! command -v %s >/dev/null 2>&1; then
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
		launch_command,
		launch_command
	)

	-- Native exec rules avoid routing startup through hyprctl's Lua dispatcher.
	rules.workspace = string.format('%d silent', workspace)
	hl.exec_cmd(command, rules)
end

hl.on('hyprland.start', function()
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
	start_once('waybar', '(^|/)waybar($| )', 'waybar')

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

	start_once('hypridle', '(^|/)hypridle($| )', 'hypridle')
	start_once('hyprpaper', '(^|/)hyprpaper($| )', 'hyprpaper')

	-- App rules here apply only to these startup launches, not future windows.
	start_on_workspace('ghostty', 1, [[
sh -c '
if ! tmux list-sessions >/dev/null 2>&1; then
    script="$HOME/shs/tmux-init.sh"
    if [ -x "$script" ]; then
        "$script"
    fi
fi

exec ghostty -e tmux new-session -A -s home
'
]])

	local zen_urgent_subscription
	zen_urgent_subscription = hl.on('window.urgent', function(window)
		if window.initial_class ~= 'zen' or not window.workspace or window.workspace.id ~= 2 then
			return
		end

		-- Focusing Zen clears its startup urgency before returning to workspace 1.
		hl.dispatch(hl.dsp.focus({ window = window }))
		hl.timer(function()
			-- Waybar needs one update cycle with workspace 2 active to drop urgent.
			hl.dispatch(hl.dsp.focus({ workspace = 1 }))
		end, { timeout = 100, type = 'oneshot' })
		zen_urgent_subscription:remove()
	end)

	hl.timer(function()
		if zen_urgent_subscription:is_active() then
			zen_urgent_subscription:remove()
		end
	end, { timeout = 10000, type = 'oneshot' })

	start_on_workspace('zen-browser', 2, nil, { suppress_event = 'activate' })
	hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)
