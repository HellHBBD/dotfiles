-- Reduced-effects preset for battery use, troubleshooting or weak GPUs.

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 4,
        gaps_workspaces = 8,
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = false,
        },

        shadow = {
            enabled = false,
        },

        dim_inactive = false,
        dim_strength = 0.0,
        dim_special = 0.0,
    },

    animations = {
        enabled = false,
    },
})
