-- Global compatibility and layout rules.
--
-- Keep global rules conservative: application-specific behavior belongs in
-- later files.

hl.window_rule({
    name = "suppress-maximize-events",

    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

-- Official compatibility workaround for empty XWayland drag surfaces.

hl.window_rule({
    name = "fix-xwayland-drags",

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

-- Shadows are unnecessary for tiled windows and add rendering work.

hl.window_rule({
    name = "no-shadow-for-tiled-windows",

    match = {
        float = false,
    },

    no_shadow = true,
})
