-- Layer-shell rules.
--
-- Verify actual namespaces after reinstalling with:
--
--     hyprctl layers
--
-- Waybar

hl.layer_rule({
    name = "waybar-appearance",

    match = {
        namespace = "^waybar$",
    },

    blur = true,
    ignore_alpha = 0.20,
    xray = true,
})

-- Fuzzel commonly uses the "launcher" namespace.

hl.layer_rule({
    name = "fuzzel-appearance",

    match = {
        namespace = "^(launcher|fuzzel)$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.15,
})

-- SwayNC control center.

hl.layer_rule({
    name = "swaync-control-center",

    match = {
        namespace = "^swaync-control-center$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.15,
})

-- SwayNC notification surfaces.

hl.layer_rule({
    name = "swaync-notifications",

    match = {
        namespace = "^swaync-notification-window$",
    },

    blur = true,
    ignore_alpha = 0.15,
})

-- Wlogout power menu.

hl.layer_rule({
    name = "wlogout-appearance",

    match = {
        namespace = "^(wlogout|logout_dialog)$",
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.10,
    dim_around = true,
})

-- Region-selection overlays should appear and disappear immediately.

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
        namespace = "^hyprpicker$",
    },

    no_anim = true,
})
