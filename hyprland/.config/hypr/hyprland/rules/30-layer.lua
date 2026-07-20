-- Layer-shell rules.
--
-- Actual namespaces can later be checked with:
--
--     hyprctl layers
--
-- The expressions below include both common upstream namespaces and names
-- remembered from the previous configuration.

-- Waybar

hl.layer_rule({
    name = "waybar-blur",

    match = {
        namespace = "^(waybar)$",
    },

    blur = true,
    ignore_alpha = 0.20,
    xray = true,
})

-- Fuzzel commonly uses the "launcher" namespace.

hl.layer_rule({
    name = "launcher-blur",

    match = {
        namespace = "^(launcher|fuzzel)$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.15,
    animation = "popin 92%",
})

-- SwayNC control center.

hl.layer_rule({
    name = "swaync-control-center",

    match = {
        namespace = "^(swaync-control-center|control-center)$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.15,
    animation = "slide",
})

-- SwayNC notification surfaces.

hl.layer_rule({
    name = "swaync-notifications",

    match = {
        namespace = "^(swaync-notification-window|notifications)$",
    },

    blur = true,
    ignore_alpha = 0.15,
    animation = "popin 90%",
})

-- Wlogout may expose either wlogout or logout_dialog depending on version
-- and configuration.

hl.layer_rule({
    name = "wlogout",

    match = {
        namespace = "^(wlogout|logout_dialog)$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.10,
    dim_around = true,
    animation = "fade",
})

-- Screenshot region selectors should appear immediately.

hl.layer_rule({
    name = "selection-no-animation",

    match = {
        namespace = "^(selection|slurp)$",
    },

    no_anim = true,
})

-- Hyprpicker overlays should not leave transitional frames behind.

hl.layer_rule({
    name = "hyprpicker-no-animation",

    match = {
        namespace = "^(hyprpicker)$",
    },

    no_anim = true,
})

-- Generic indicator overlays such as volume and brightness popups.

hl.layer_rule({
    name = "indicator-overlay",

    match = {
        namespace = "^(indicator.*)$",
    },

    blur = true,
    ignore_alpha = 0.20,
    animation = "popin 90%",
})
