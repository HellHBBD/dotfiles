-- Shared compositor behavior.
--
-- Visual intensity is controlled separately by presets/current.lua.

hl.config({
	general = {
		border_size = 1,
		resize_on_border = true,
		no_focus_fallback = true,

		layout = 'dwindle',
		allow_tearing = true,

		col = {
			active_border = 'rgba(0DB7D4FF)',
			inactive_border = 'rgba(31313600)',
		},

		snap = {
			enabled = true,
			window_gap = 4,
			monitor_gap = 5,
			respect_gaps = true,
		},
	},

	decoration = {
		rounding_power = 2.5,

		active_opacity = 1.0,
		inactive_opacity = 1.0,
		fullscreen_opacity = 1.0,
	},

	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = false,
	},

	binds = {
		scroll_event_delay = 0,
	},

	misc = {
		vrr = 3,

		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,

		disable_hyprland_logo = true,
		force_default_wallpaper = 0,

		on_focus_under_fullscreen = 2,
		allow_session_lock_restore = true,
	},

	debug = {
		vfr = true,
	},
})
