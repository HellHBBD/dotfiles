-- Full desktop keybinds.
--
-- Safety-critical keybinds remain in safety.lua and are not duplicated.

local function managed_app(command)
    return string.format([[
if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- %s
else
    exec %s
fi
]], command, command)
end

local launcher_command = [[
if pgrep -x fuzzel >/dev/null 2>&1; then
    pkill -x fuzzel
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- fuzzel --launch-prefix='uwsm app --'
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

grim - | wl-copy

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot" "Full screen copied to clipboard"
fi
]]

local wlogout_command = [[
if pgrep -x wlogout >/dev/null 2>&1; then
    pkill -x wlogout
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- wlogout -p layer-shell
else
    exec wlogout -p layer-shell
fi
]]

-- Applications

hl.bind(
    "SUPER + D",
    hl.dsp.exec_cmd(launcher_command),
    {
        description = "Application launcher",
    }
)

hl.bind(
    "SUPER + E",
    hl.dsp.exec_cmd(managed_app("dolphin")),
    {
        description = "Open file manager",
    }
)

hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd(clipboard_command),
    {
        description = "Clipboard history",
    }
)

-- Session

hl.bind(
    "SUPER + N",
    hl.dsp.exec_cmd("swaync-client -t -sw"),
    {
        description = "Toggle notification center",
    }
)

hl.bind(
    "SUPER + SHIFT + N",
    hl.dsp.exec_cmd("swaync-client -d -sw"),
    {
        description = "Toggle do-not-disturb",
    }
)

hl.bind(
    "SUPER + L",
    hl.dsp.exec_cmd(managed_app("hyprlock")),
    {
        description = "Lock session",
    }
)

hl.bind(
    "CTRL + SHIFT + ALT + Delete",
    hl.dsp.exec_cmd(wlogout_command),
    {
        description = "Open power menu",
    }
)

-- Screenshots and color picker

hl.bind(
    "SUPER + SHIFT + S",
    hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/screenshot-area.sh"),
    {
        description = "Copy selected screenshot",
    }
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
    hl.dsp.exec_cmd(managed_app("hyprpicker -a")),
    {
        description = "Pick color",
    }
)

-- Move active window

hl.bind(
    "SUPER + SHIFT + Left",
    hl.dsp.window.move({ direction = "l" }),
    {
        description = "Move window left",
    }
)

hl.bind(
    "SUPER + SHIFT + Right",
    hl.dsp.window.move({ direction = "r" }),
    {
        description = "Move window right",
    }
)

hl.bind(
    "SUPER + SHIFT + Up",
    hl.dsp.window.move({ direction = "u" }),
    {
        description = "Move window up",
    }
)

hl.bind(
    "SUPER + SHIFT + Down",
    hl.dsp.window.move({ direction = "d" }),
    {
        description = "Move window down",
    }
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
    {
        description = "Toggle split direction",
    }
)

-- Workspace 1-10

for index = 1, 10 do
    local key = tostring(index % 10)

    hl.bind(
        "SUPER + " .. key,
        hl.dsp.focus({ workspace = index }),
        {
            description = "Focus workspace " .. index,
        }
    )

    hl.bind(
        "SUPER + ALT + " .. key,
        hl.dsp.window.move({
            workspace = index,
            follow = false,
        }),
        {
            description = "Move window silently to workspace " .. index,
        }
    )

    hl.bind(
        "SUPER + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = index,
            follow = true,
        }),
        {
            description = "Move window and follow to workspace " .. index,
        }
    )
end

-- Relative workspace navigation

hl.bind(
    "CTRL + SUPER + Right",
    hl.dsp.focus({ workspace = "r+1" }),
    {
        description = "Next workspace on monitor",
    }
)

hl.bind(
    "CTRL + SUPER + Left",
    hl.dsp.focus({ workspace = "r-1" }),
    {
        description = "Previous workspace on monitor",
    }
)

hl.bind(
    "SUPER + mouse_up",
    hl.dsp.focus({ workspace = "+1" }),
    {
        description = "Next workspace",
    }
)

hl.bind(
    "SUPER + mouse_down",
    hl.dsp.focus({ workspace = "-1" }),
    {
        description = "Previous workspace",
    }
)

-- Scratchpad workspace

hl.bind(
    "SUPER + S",
    hl.dsp.workspace.toggle_special("scratch"),
    {
        description = "Toggle scratchpad",
    }
)

hl.bind(
    "SUPER + ALT + S",
    hl.dsp.window.move({
        workspace = "special:scratch",
        follow = false,
    }),
    {
        description = "Move window to scratchpad",
    }
)

-- Window navigation

hl.bind(
    "ALT + Tab",
    hl.dsp.window.cycle_next({ next = true }),
    {
        description = "Cycle to next window",
    }
)

hl.bind(
    "SUPER + P",
    hl.dsp.window.pin(),
    {
        description = "Toggle window pin",
    }
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
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
    {
        locked = true,
        repeating = true,
        description = "Increase brightness",
    }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
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
    {
        locked = true,
        description = "Play or pause media",
    }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    {
        locked = true,
        description = "Play or pause media",
    }
)

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    {
        locked = true,
        description = "Next media track",
    }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    {
        locked = true,
        description = "Previous media track",
    }
)
