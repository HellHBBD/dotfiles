-- Global window rules.

hl.window_rule({
    name = "suppress-maximize-requests",

    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

-- Prevent empty XWayland drag surfaces from stealing focus.

hl.window_rule({
    name = "fix-xwayland-drag-surfaces",

    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },

    no_focus = true,
})

-- Tiled windows do not need shadows because they already occupy the
-- compositor layout and touch adjacent gaps.

hl.window_rule({
    name = "no-shadow-for-tiled-windows",

    match = {
        float = false,
    },

    no_shadow = true,
})

-- Prevent applications from disabling compositor shortcuts.

hl.window_rule({
    name = "prevent-shortcut-inhibit",

    match = {
        class = ".*",
    },

    no_shortcuts_inhibit = true,
})
