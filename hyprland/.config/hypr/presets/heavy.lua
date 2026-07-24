-- High-visual-quality preset.
--
-- This approximates the older, heavier end-4-inspired appearance.

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 5,
		gaps_workspaces = 50,
	},

	decoration = {
		rounding = 20,

		blur = {
			enabled = true,
			size = 14,
			passes = 3,

			brightness = 1.0,
			contrast = 1.0,
			noise = 0.01,
		},

		shadow = {
			enabled = true,
			range = 30,
			offset = { 0, 2 },
			render_power = 4,
			color = 'rgba(0000002A)',
		},

		dim_inactive = true,
		dim_strength = 0.05,
		dim_special = 0.10,
	},

	animations = {
		enabled = true,
	},
})
