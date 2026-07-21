-- Minimal Hyprland bring-up configuration.
--
-- This file intentionally avoids desktop services, rules, animations,
-- presets, custom scripts, and machine-specific overrides.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 5,
        border_size = 1,
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled = false,
        },

        shadow = {
            enabled = false,
        },
    },

    animations = {
        enabled = false,
    },

    input = {
        kb_layout = "us",
        kb_options = "ctrl:nocaps",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            tap_to_click = true,
            tap_and_drag = true,
            scroll_factor = 0.5,
        },
    },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
    },
})

hl.bind(
    "SUPER + Return",
    hl.dsp.exec_cmd("ghostty"),
    {
        description = "Open terminal",
    }
)

hl.bind(
    "SUPER + Q",
    hl.dsp.window.close(),
    {
        description = "Close window",
    }
)

local exit_command = [[
if command -v hyprshutdown >/dev/null 2>&1; then
    exec hyprshutdown
fi

exec hyprctl dispatch exit
]]

hl.bind(
    "SUPER + SHIFT + M",
    hl.dsp.exec_cmd(exit_command),
    {
        description = "Exit Hyprland",
    }
)

for key, direction in pairs({
    Left = "l",
    Right = "r",
    Up = "u",
    Down = "d",
}) do
    hl.bind(
        "SUPER + " .. key,
        hl.dsp.focus({ direction = direction })
    )
end

for index = 1, 10 do
    local key = tostring(index % 10)

    hl.bind(
        "SUPER + " .. key,
        hl.dsp.focus({ workspace = index })
    )

    hl.bind(
        "SUPER + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = index,
            follow = false,
        })
    )
end
