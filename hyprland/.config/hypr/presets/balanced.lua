-- Daily-use preset.
--
-- Keeps the original card-like appearance while reducing the heavier
-- blur and workspace gaps from the older configuration.

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 5,
        gaps_workspaces = 16,
    },

    decoration = {
        rounding = 18,

        blur = {
            enabled = true,
            size = 9,
            passes = 2,

            brightness = 1.0,
            contrast = 1.0,
            noise = 0.01,
        },

        shadow = {
            enabled = true,
            range = 20,
            offset = { 0, 2 },
            render_power = 3,
            color = "rgba(0000002A)",
        },

        dim_inactive = true,
        dim_strength = 0.02,
        dim_special = 0.05,
    },

    animations = {
        enabled = true,
    },
})
