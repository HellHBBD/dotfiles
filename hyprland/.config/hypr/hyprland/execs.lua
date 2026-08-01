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

if command -v uwsm >/dev/null 2>&1; then
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
	start_once(
		'swayosd-server',
		'(^|/)swayosd-server($| )',
		'env GSK_RENDERER=gl swayosd-server'
	)

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
script="$HOME/shs/tmux-init.sh"
if [ -x "$script" ]; then
    "$script"
fi

exec ghostty -e tmux new-session -A -s home
'
]])

	local startup_urgent_targets = {
		[2] = 'zen',
		[3] = 'com.mitchellh.ghostty',
	}
	local startup_urgent_timeout = 60000
	local startup_urgent_workspaces = {}
	local startup_urgent_windows = {}
	local startup_urgent_subscription
	local processing_startup_urgent = false

	local function all_startup_urgents_cleared()
		for workspace in pairs(startup_urgent_targets) do
			if not startup_urgent_workspaces[workspace] then
				return false
			end
		end
		return true
	end

	local function clear_next_startup_urgent()
		local window = table.remove(startup_urgent_windows, 1)
		if not window then
			processing_startup_urgent = false
			if all_startup_urgents_cleared() then
				startup_urgent_subscription:remove()
			end
			return
		end

		-- Waybar needs one update cycle with the target workspace active to drop urgent.
		processing_startup_urgent = true
		hl.dispatch(hl.dsp.focus({ window = window }))
		hl.timer(function()
			hl.dispatch(hl.dsp.focus({ workspace = 1 }))
			clear_next_startup_urgent()
		end, { timeout = 100, type = 'oneshot' })
	end

	startup_urgent_subscription = hl.on('window.urgent', function(window)
		local workspace = window.workspace
		if not workspace or
			startup_urgent_targets[workspace.id] ~= window.initial_class or
			startup_urgent_workspaces[workspace.id] then
			return
		end

		startup_urgent_workspaces[workspace.id] = true
		table.insert(startup_urgent_windows, window)
		if not processing_startup_urgent then
			clear_next_startup_urgent()
		end
	end)

	hl.timer(function()
		if startup_urgent_subscription:is_active() then
			startup_urgent_subscription:remove()
		end
	end, { timeout = startup_urgent_timeout, type = 'oneshot' })

	start_on_workspace('zen-browser', 2, nil, { suppress_event = 'activate' })
	start_on_workspace('ghostty', 3, [[
sh -c '
if ! command -v herdr >/dev/null 2>&1; then
    exit 0
fi

exec ghostty -e herdr
'
]])
	hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)
