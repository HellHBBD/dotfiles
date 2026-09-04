-- Full desktop keybinds.
--
-- Safety-critical keybinds remain in safety.lua and are not duplicated.

local function managed_app(command)
	return string.format(
		[[
if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- %s
else
    exec %s
fi
]],
		command,
		command
	)
end

local launcher_command = [[
if pgrep -x fuzzel >/dev/null 2>&1; then
    pkill -x fuzzel
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- fuzzel
else
    exec fuzzel
fi
]]

local clipboard_command = [[
if pgrep -x fuzzel >/dev/null 2>&1; then
    pkill -x fuzzel
    exit 0
fi

command -v cliphist >/dev/null 2>&1 || exit 1
command -v fuzzel >/dev/null 2>&1 || exit 1
command -v wl-copy >/dev/null 2>&1 || exit 1

selection="$(
    if command -v uwsm >/dev/null 2>&1 &&
       systemctl --user is-active --quiet 'wayland-session@*.target'; then
        cliphist list |
            uwsm app -- fuzzel \
                --dmenu \
                --match-mode=fzf \
                --prompt='Clipboard > '
    else
        cliphist list |
            fuzzel \
                --dmenu \
                --match-mode=fzf \
                --prompt='Clipboard > '
    fi
)" || exit 0

printf '%s\n' "$selection" |
    cliphist decode |
    wl-copy
]]

local screenshot_screen_command = [[
command -v grim >/dev/null 2>&1 || exit 1
command -v wl-copy >/dev/null 2>&1 || exit 1

directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$directory"
file="$directory/$(date '+%Y-%m-%d_%H-%M-%S').png"

if grim "$file"; then
    wl-copy <"$file"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "截圖已儲存" "$file"
    fi
else
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical "截圖失敗" "grim 無法擷取全螢幕"
    fi
    exit 1
fi
]]

local wlogout_command = [[
if pgrep -x wlogout >/dev/null 2>&1; then
    pkill -x wlogout
    exit 0
fi

dimensions=$(hyprctl -j monitors 2>/dev/null |
    jq -r 'map(select(.focused))[0] | "\((.width / .scale | floor)) \((.height / .scale | floor))"' 2>/dev/null)
set -- $dimensions

if [ "$#" -eq 2 ] && [ "$1" -ge 576 ] && [ "$2" -ge 195 ]; then
    horizontal_margin=$((($1 - 576) / 2))
    vertical_margin=$((($2 - 195) / 2))
fi

set -- wlogout -p layer-shell --buttons-per-row 2 --column-spacing 16
if [ -n "${horizontal_margin:-}" ]; then
    # Constrain the grid to the configured 280x195 button size.
    set -- "$@" \
        --margin-left "$horizontal_margin" \
        --margin-right "$horizontal_margin" \
        --margin-top "$vertical_margin" \
        --margin-bottom "$vertical_margin"
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- "$@"
else
    exec "$@"
fi
]]

-- Applications

hl.bind(
	'SUPER + Slash',
	hl.dsp.exec_cmd(managed_app('python3 ~/.config/hypr/keybind-cheatsheet/app.py')),
	{
		description = '應用程式 | 快捷鍵總覽 | cheatsheet hotkeys reference',
	}
)

hl.bind('SUPER + D', hl.dsp.exec_cmd(launcher_command), {
	description = '應用程式 | 應用程式啟動器 | app launcher',
})

hl.bind('SUPER + E', hl.dsp.exec_cmd(managed_app('dolphin')), {
	description = '應用程式 | 檔案管理員 | file manager dolphin',
})

hl.bind(
	'SUPER + SHIFT + Return',
	hl.dsp.exec_cmd([[
if command -v uwsm >/dev/null 2>&1; then
    exec uwsm app -- zen-browser
else
    exec zen-browser
fi
]]),
	{
		description = '應用程式 | 瀏覽器 | browser zen',
	}
)

hl.bind('SUPER + V', hl.dsp.exec_cmd(clipboard_command), {
	description = '應用程式 | 剪貼簿歷史 | clipboard copy paste',
})

-- Session

hl.bind('SUPER + N', hl.dsp.exec_cmd('swaync-client -t -sw'), {
	description = '系統 | 通知中心 | notification center swaync',
})

hl.bind('SUPER + SHIFT + N', hl.dsp.exec_cmd('swaync-client -d -sw'), {
	description = '系統 | 勿擾模式 | do not disturb dnd',
})

hl.bind('SUPER + L', hl.dsp.exec_cmd(managed_app('hyprlock')), {
	description = '系統 | 鎖定畫面 | lock session hyprlock',
})

hl.bind('SUPER + SHIFT + P', hl.dsp.exec_cmd('bash ~/.config/hypr/scripts/display-mode.sh'), {
	description = '系統 | 顯示器模式 | display monitor mode',
})

hl.bind('CTRL + ALT + Delete', hl.dsp.exec_cmd(wlogout_command), {
	description = '系統 | 電源選單 | power logout shutdown reboot',
})

-- Screenshots and color picker

hl.bind('SUPER + SHIFT + S', hl.dsp.exec_cmd('bash ~/.config/hypr/scripts/screenshot-area.sh'), {
	description = '螢幕擷取 | 選取區域截圖 | screenshot capture area',
})

hl.bind('Print', hl.dsp.exec_cmd(screenshot_screen_command), {
	locked = true,
	description = '螢幕擷取 | 全螢幕截圖 | screenshot capture full screen',
})

hl.bind('SUPER + SHIFT + C', hl.dsp.exec_cmd(managed_app('hyprpicker -a')), {
	description = '螢幕擷取 | 色彩擷取 | color picker',
})

-- Move active window

hl.bind('SUPER + SHIFT + Left', hl.dsp.window.move({ direction = 'l' }), {
	description = '視窗管理 | 移動視窗 | window move',
})

hl.bind('SUPER + SHIFT + Right', hl.dsp.window.move({ direction = 'r' }), {
	description = '視窗管理 | 移動視窗 | window move',
})

hl.bind('SUPER + SHIFT + Up', hl.dsp.window.move({ direction = 'u' }), {
	description = '視窗管理 | 移動視窗 | window move',
})

hl.bind('SUPER + SHIFT + Down', hl.dsp.window.move({ direction = 'd' }), {
	description = '視窗管理 | 移動視窗 | window move',
})

-- Dwindle split ratio

hl.bind('SUPER + Minus', hl.dsp.layout('splitratio -0.1'), {
	repeating = true,
	description = '視窗管理 | 調整分割比例 | layout split ratio',
})

hl.bind('SUPER + Equal', hl.dsp.layout('splitratio +0.1'), {
	repeating = true,
	description = '視窗管理 | 調整分割比例 | layout split ratio',
})

hl.bind('SUPER + T', hl.dsp.layout('togglesplit'), {
	description = '視窗管理 | 切換分割方向 | layout split direction',
})

-- Workspace 1-10

for index = 1, 10 do
	local key = tostring(index % 10)

	hl.bind('SUPER + ' .. key, hl.dsp.focus({ workspace = index }), {
		description = '工作區 | 切換工作區 | workspace focus',
	})

	hl.bind(
		'SUPER + ALT + ' .. key,
		hl.dsp.window.move({
			workspace = index,
			follow = false,
		}),
		{
			description = '工作區 | 移動視窗至工作區 | workspace move',
		}
	)

	hl.bind(
		'SUPER + SHIFT + ' .. key,
		hl.dsp.window.move({
			workspace = index,
			follow = true,
		}),
		{
			description = '工作區 | 移動並跟隨 | workspace move follow',
		}
	)
end

-- Relative workspace navigation

hl.bind('CTRL + SUPER + Right', hl.dsp.focus({ workspace = 'r+1' }), {
	description = '工作區 | 切換相鄰工作區 | workspace next previous',
})

hl.bind('CTRL + SUPER + Left', hl.dsp.focus({ workspace = 'r-1' }), {
	description = '工作區 | 切換相鄰工作區 | workspace next previous',
})

hl.bind('SUPER + mouse_up', hl.dsp.focus({ workspace = '+1' }), {
	description = '工作區 | 切換相鄰工作區 | workspace next previous',
})

hl.bind('SUPER + mouse_down', hl.dsp.focus({ workspace = '-1' }), {
	description = '工作區 | 切換相鄰工作區 | workspace next previous',
})

-- Scratchpad workspace

hl.bind('SUPER + S', hl.dsp.workspace.toggle_special('scratch'), {
	description = '工作區 | 暫存視窗 | scratchpad special workspace',
})

hl.bind(
	'SUPER + ALT + S',
	hl.dsp.window.move({
		workspace = 'special:scratch',
		follow = false,
	}),
	{
		description = '工作區 | 移至暫存區 | scratchpad special workspace',
	}
)

-- Window navigation

hl.bind('ALT + Tab', hl.dsp.window.cycle_next({ next = true }), {
	description = '視窗管理 | 下一個視窗 | window cycle alt tab',
})

hl.bind('SUPER + P', hl.dsp.window.pin(), {
	description = '視窗管理 | 視窗置頂 | window pin',
})

-- Audio

hl.bind(
	'XF86AudioRaiseVolume',
	hl.dsp.exec_cmd('swayosd-client --output-volume +5 --max-volume 100'),
	{
		locked = true,
		repeating = true,
		description = '媒體與硬體 | 調整音量 | volume audio',
	}
)

hl.bind(
	'XF86AudioLowerVolume',
	hl.dsp.exec_cmd('swayosd-client --output-volume -5 --max-volume 100'),
	{
		locked = true,
		repeating = true,
		description = '媒體與硬體 | 調整音量 | volume audio',
	}
)

hl.bind('XF86AudioMute', hl.dsp.exec_cmd('swayosd-client --output-volume mute-toggle'), {
	locked = true,
	description = '媒體與硬體 | 輸出靜音 | volume mute audio',
})

hl.bind('XF86AudioMicMute', hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'), {
	locked = true,
	description = '媒體與硬體 | 麥克風靜音 | microphone mute audio',
})

-- Display brightness

hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd('swayosd-client --brightness +5'), {
	locked = true,
	repeating = true,
	description = '媒體與硬體 | 調整亮度 | brightness display',
})

hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd('swayosd-client --brightness -5'), {
	locked = true,
	repeating = true,
	description = '媒體與硬體 | 調整亮度 | brightness display',
})

-- Media controls

hl.bind('XF86AudioPlay', hl.dsp.exec_cmd('playerctl play-pause'), {
	locked = true,
	description = '媒體與硬體 | 播放／暫停 | media play pause',
})

hl.bind('XF86AudioPause', hl.dsp.exec_cmd('playerctl play-pause'), {
	locked = true,
	description = '媒體與硬體 | 播放／暫停 | media play pause',
})

hl.bind('XF86AudioNext', hl.dsp.exec_cmd('playerctl next'), {
	locked = true,
	description = '媒體與硬體 | 切換曲目 | media next previous',
})

hl.bind('XF86AudioPrev', hl.dsp.exec_cmd('playerctl previous'), {
	locked = true,
	description = '媒體與硬體 | 切換曲目 | media next previous',
})
