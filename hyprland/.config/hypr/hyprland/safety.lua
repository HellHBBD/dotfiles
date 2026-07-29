-- Permanent safety keybinds.
--
-- These must continue working even when Waybar, Fuzzel, SwayNC, Hypridle or
-- other optional components fail.

local terminal_command = [[
for terminal in ghostty foot kitty alacritty; do
    if command -v "$terminal" >/dev/null 2>&1; then
        if [ "$terminal" = ghostty ] && command -v uwsm >/dev/null 2>&1; then
            exec uwsm app -- "$terminal"
        fi
        exec "$terminal"
    fi
done

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Hyprland" "No supported terminal was found"
fi

exit 127
]]

local exit_session_command = 'bash ~/.config/hypr/scripts/logout-session.sh'

hl.bind('SUPER + Return', hl.dsp.exec_cmd(terminal_command), {
	description = '應用程式 | 終端機 | terminal shell',
})

hl.bind('SUPER + Q', hl.dsp.window.close(), {
	description = '視窗管理 | 關閉視窗 | close kill window',
})

hl.bind('SUPER + SHIFT + M', hl.dsp.exec_cmd(exit_session_command), {
	description = '系統 | 結束工作階段 | logout exit session',
})

hl.bind('SUPER + ALT + Space', hl.dsp.window.float({ action = 'toggle' }), {
	description = '視窗管理 | 浮動視窗 | floating toggle',
})

hl.bind(
	'SUPER + F',
	hl.dsp.window.fullscreen({
		mode = 'fullscreen',
		action = 'toggle',
	}),
	{
		description = '視窗管理 | 全螢幕 | fullscreen toggle',
	}
)

hl.bind('SUPER + Left', hl.dsp.focus({ direction = 'l' }), {
	description = '視窗管理 | 聚焦視窗 | window focus',
})

hl.bind('SUPER + Right', hl.dsp.focus({ direction = 'r' }), {
	description = '視窗管理 | 聚焦視窗 | window focus',
})

hl.bind('SUPER + Up', hl.dsp.focus({ direction = 'u' }), {
	description = '視窗管理 | 聚焦視窗 | window focus',
})

hl.bind('SUPER + Down', hl.dsp.focus({ direction = 'd' }), {
	description = '視窗管理 | 聚焦視窗 | window focus',
})

hl.bind('SUPER + mouse:272', hl.dsp.window.drag(), {
	mouse = true,
	description = '視窗管理 | 拖曳視窗 | window drag mouse',
})

hl.bind('SUPER + mouse:273', hl.dsp.window.resize(), {
	mouse = true,
	description = '視窗管理 | 調整視窗大小 | window resize mouse',
})
