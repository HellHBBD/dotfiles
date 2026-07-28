-- Application and content-specific rules.

hl.window_rule({
	name = 'hyprland-keybind-cheatsheet',

	match = {
		initial_class = [[^com\.hellhbbd\.HyprlandCheatsheet$]],
	},

	float = true,
	center = true,

	size = {
		'1100',
		'720',
	},

	persistent_size = true,
})

-- Browser Picture-in-Picture windows.
--
-- The size and position are monitor-local expressions.

hl.window_rule({
	name = 'picture-in-picture',

	match = {
		initial_title = [[^(Picture-in-Picture|Picture in picture|Picture in Picture)$]],
	},

	float = true,
	pin = true,
	no_initial_focus = true,

	size = {
		'monitor_w*0.25',
		'monitor_h*0.25',
	},

	move = {
		'monitor_w-window_w-20',
		'monitor_h-window_h-60',
	},

	keep_aspect_ratio = true,
})

-- Prevent sleep while fullscreen video content is active, including players
-- that expose the video content type directly.

hl.window_rule({
	name = 'fullscreen-video-idle-inhibit',

	match = {
		content = 'video',
		fullscreen = true,
	},

	idle_inhibit = 'fullscreen',
})

-- Steam games.

hl.window_rule({
	name = 'steam-games-content',

	match = {
		class = '^steam_app_.*$',
	},

	content = 'game',
	immediate = true,
	focus_on_activate = true,
	idle_inhibit = 'fullscreen',
})

-- Minecraft windows.
--
-- Confirm the actual class after reinstalling with:
--
--     hyprctl clients

hl.window_rule({
	name = 'minecraft-content',

	match = {
		initial_class = '^(Minecraft.*|minecraft.*)$',
	},

	content = 'game',
	immediate = true,
	focus_on_activate = true,
	idle_inhibit = 'fullscreen',
})

hl.window_rule({
	name = 'fullscreen-browser-idle-inhibit',

	match = {
		class = [[^(firefox|zen|zen-browser|Brave-browser|brave-browser|chromium|google-chrome)$]],
		fullscreen = true,
	},

	idle_inhibit = 'fullscreen',
})
