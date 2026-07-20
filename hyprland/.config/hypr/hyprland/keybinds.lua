-- Full desktop keybinds.
--
-- Safety-critical binds remain in safety.lua and are not duplicated here.

local launcher_command = [[
pkill -x fuzzel 2>/dev/null || exec fuzzel
]]

local clipboard_command = [[
pkill -x fuzzel 2>/dev/null && exit 0

cliphist list |
    fuzzel --dmenu --match-mode=fzf --prompt="Clipboard > " |
    cliphist decode |
    wl-copy
]]

local screenshot_area_command = [[
geometry="$(slurp)" || exit 0
grim -g "$geometry" - | wl-copy
notify-send "Screenshot" "Selected area copied to clipboard"
]]

local screenshot_screen_command = [[
grim - | wl-copy
notify-send "Screenshot" "Screen copied to clipboard"
]]

local wlogout_command = [[
]]

-- Applications

hl.bind(
    "SUPER + Space",
    hl.dsp.exec_cmd(launcher_command),
    { description = "Application launcher" }
)

hl.bind(
    "SUPER + E",
    hl.dsp.exec_cmd("dolphin"),
    { description = "Open file manager" }
)

hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd(clipboard_command),
    { description = "Clipboard history" }
)

-- Session

hl.bind(
    "SUPER + L",
    hl.dsp.exec_cmd("hyprlock"),
    { description = "Lock session" }
)

hl.bind(
    "CTRL + SHIFT + ALT + Delete",
    hl.dsp.exec_cmd(wlogout_command),
    { description = "Open power menu" }
)

-- Screenshots and color picker

hl.bind(
    "SUPER + SHIFT + S",
    hl.dsp.exec_cmd(screenshot_area_command),
    { description = "Copy selected screenshot" }
)

hl.bind(
    "Print",
    hl.dsp.exec_cmd(screenshot_screen_command),
    {
        locked = true,
        description = "Copy full-screen screenshot",
    }
)

hl.bind(
    "SUPER + SHIFT + C",
    hl.dsp.exec_cmd("hyprpicker -a"),
    { description = "Pick color" }
)

-- Move active window

hl.bind(
    "SUPER + SHIFT + Left",
    hl.dsp.window.move({ direction = "l" }),
    { description = "Move window left" }
)

hl.bind(
    "SUPER + SHIFT + Right",
    hl.dsp.window.move({ direction = "r" }),
    { description = "Move window right" }
)

hl.bind(
    "SUPER + SHIFT + Up",
    hl.dsp.window.move({ direction = "u" }),
    { description = "Move window up" }
)

hl.bind(
    "SUPER + SHIFT + Down",
    hl.dsp.window.move({ direction = "d" }),
    { description = "Move window down" }
)

-- Dwindle split ratio

hl.bind(
    "SUPER + Minus",
    hl.dsp.layout("splitratio -0.1"),
    {
        repeating = true,
        description = "Decrease split ratio",
    }
)

hl.bind(
    "SUPER + Equal",
    hl.dsp.layout("splitratio +0.1"),
    {
        repeating = true,
        description = "Increase split ratio",
    }
)

hl.bind(
    "SUPER + T",
    hl.dsp.layout("togglesplit"),
    { description = "Toggle split direction" }
)

-- Workspace 1-10

for index = 1, 10 do
    local key = index == 10 and "0" or tostring(index)
    local workspace = tostring(index)

    hl.bind(
        "SUPER + " .. key,
        hl.dsp.focus({ workspace = workspace }),
        { description = "Focus workspace " .. workspace }
    )

    hl.bind(
        "SUPER + ALT + " .. key,
        hl.dsp.window.move({
            workspace = workspace,
            follow = false,
        }),
        { description = "Move window silently to workspace " .. workspace }
    )

    hl.bind(
        "SUPER + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = workspace,
            follow = true,
        }),
        { description = "Move window and follow to workspace " .. workspace }
    )
end

-- Relative workspace navigation

hl.bind(
    "CTRL + SUPER + Right",
    hl.dsp.focus({ workspace = "r+1" }),
    { description = "Next workspace" }
)

hl.bind(
    "CTRL + SUPER + Left",
    hl.dsp.focus({ workspace = "r-1" }),
    { description = "Previous workspace" }
)

hl.bind(
    "SUPER + mouse_down",
    hl.dsp.focus({ workspace = "e+1" })
)

hl.bind(
    "SUPER + mouse_up",
    hl.dsp.focus({ workspace = "e-1" })
)

-- Scratchpad workspace

hl.bind(
    "SUPER + S",
    hl.dsp.workspace.toggle_special("scratch"),
    { description = "Toggle scratchpad" }
)

hl.bind(
    "SUPER + ALT + S",
    hl.dsp.window.move({
        workspace = "special:scratch",
        follow = false,
    }),
    { description = "Move window to scratchpad" }
)

-- Window navigation

hl.bind(
    "ALT + Tab",
    hl.dsp.window.cycle_next({ next = true }),
    { description = "Cycle to next window" }
)

hl.bind(
    "SUPER + P",
    hl.dsp.window.pin(),
    { description = "Pin floating window" }
)

-- Audio

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"),
    {
        locked = true,
        repeating = true,
        description = "Increase volume",
    }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
    {
        locked = true,
        repeating = true,
        description = "Decrease volume",
    }
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    {
        locked = true,
        description = "Toggle output mute",
    }
)

hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    {
        locked = true,
        description = "Toggle microphone mute",
    }
)

-- Display brightness

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl set 5%+"),
    {
        locked = true,
        repeating = true,
        description = "Increase brightness",
    }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl set 5%-"),
    {
        locked = true,
        repeating = true,
        description = "Decrease brightness",
    }
)

-- Media controls

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)
