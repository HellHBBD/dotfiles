-- Permanent safety keybinds.
--
-- These must continue working even when Waybar, Fuzzel, SwayNC, Hypridle or
-- other optional components fail.

local terminal_command = [[
for terminal in ghostty foot kitty alacritty; do
    if command -v "$terminal" >/dev/null 2>&1; then
        if command -v uwsm >/dev/null 2>&1 &&
           systemctl --user is-active --quiet 'wayland-session@*.target'; then
            exec uwsm app -- "$terminal"
        else
            exec "$terminal"
        fi
    fi
done

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Hyprland" "No supported terminal was found"
fi

exit 127
]]

local exit_session_command = 'bash ~/.config/hypr/scripts/logout-session.sh'

hl.bind('SUPER + Return', hl.dsp.exec_cmd(terminal_command), {
	description = 'Open terminal',
})

hl.bind('SUPER + Q', hl.dsp.window.close(), {
	description = 'Close active window',
})

hl.bind('SUPER + SHIFT + M', hl.dsp.exec_cmd(exit_session_command), {
	description = 'Exit graphical session',
})

hl.bind('SUPER + ALT + Space', hl.dsp.window.float({ action = 'toggle' }), {
	description = 'Toggle floating',
})

hl.bind(
	'SUPER + F',
	hl.dsp.window.fullscreen({
		mode = 'fullscreen',
		action = 'toggle',
	}),
	{
		description = 'Toggle fullscreen',
	}
)

hl.bind('SUPER + Left', hl.dsp.focus({ direction = 'l' }), {
	description = 'Focus left',
})

hl.bind('SUPER + Right', hl.dsp.focus({ direction = 'r' }), {
	description = 'Focus right',
})

hl.bind('SUPER + Up', hl.dsp.focus({ direction = 'u' }), {
	description = 'Focus up',
})

hl.bind('SUPER + Down', hl.dsp.focus({ direction = 'd' }), {
	description = 'Focus down',
})

hl.bind('SUPER + mouse:272', hl.dsp.window.drag(), {
	mouse = true,
	description = 'Move window with mouse',
})

hl.bind('SUPER + mouse:273', hl.dsp.window.resize(), {
	mouse = true,
	description = 'Resize window with mouse',
})
