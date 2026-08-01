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
	local startup_urgent_open = {}
	local startup_urgent_pending = {}
	local startup_urgent_generation = {}
	local startup_urgent_expired = false
	local schedule_startup_urgent_clear

	local function is_startup_urgent_target(window)
		local workspace = window.workspace
		return workspace and startup_urgent_targets[workspace.id] == window.initial_class
	end

	local function clear_startup_urgent(window)
		local id = window.stable_id
		if startup_urgent_expired or not startup_urgent_open[id] or not window.mapped then
			return
		end

		local workspace = window.workspace
		if not workspace then
			return
		end

		local restore_workspace = hl.get_active_workspace()
		hl.dispatch(hl.dsp.focus({ window = window }))
		hl.timer(function()
			local retry = not startup_urgent_expired and workspace.has_urgent
			if not retry and not startup_urgent_expired then
				startup_urgent_pending[id] = nil
			end

			if restore_workspace then
				hl.dispatch(hl.dsp.focus({ workspace = restore_workspace }))
			end
			if retry then
				schedule_startup_urgent_clear(window)
			end
		end, { timeout = 250, type = 'oneshot' })
	end

	schedule_startup_urgent_clear = function(window)
		local id = window.stable_id
		startup_urgent_pending[id] = window
		if startup_urgent_expired or not startup_urgent_open[id] then
			return
		end

		startup_urgent_generation[id] = (startup_urgent_generation[id] or 0) + 1
		local generation = startup_urgent_generation[id]
		hl.timer(function()
			if startup_urgent_generation[id] == generation then
				clear_startup_urgent(window)
			end
		end, { timeout = 500, type = 'oneshot' })
	end

	local startup_urgent_open_subscription = hl.on('window.open', function(window)
		if not is_startup_urgent_target(window) then
			return
		end

		local id = window.stable_id
		startup_urgent_open[id] = true
		if startup_urgent_pending[id] then
			schedule_startup_urgent_clear(window)
		end
	end)

	local startup_urgent_subscription = hl.on('window.urgent', function(window)
		if is_startup_urgent_target(window) then
			schedule_startup_urgent_clear(window)
		end
	end)

	hl.timer(function()
		startup_urgent_expired = true
		startup_urgent_open_subscription:remove()
		startup_urgent_subscription:remove()
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
