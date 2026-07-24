-- Dialog, settings and authentication windows.

hl.window_rule({
	name = 'modal-dialogs',

	match = {
		modal = true,
	},

	float = true,
	center = true,
	dim_around = true,
})

-- Common GTK, Qt and browser file chooser titles.
--
-- Static effects such as float, center and size use the window's initial
-- properties, so this matches the initial title explicitly.

hl.window_rule({
	name = 'file-chooser-dialogs',

	match = {
		initial_title = [[^(Open File|Select a File|Open Folder|Select Folder|Save As|File Upload|Choose wallpaper|.* wants to (open|save).*)$]],
	},

	float = true,
	center = true,

	size = {
		'monitor_w*0.60',
		'monitor_h*0.65',
	},

	persistent_size = true,
})

-- KDE portal, KDialog and System Settings modules.

hl.window_rule({
	name = 'kde-settings-and-portals',

	match = {
		initial_class = [[^(xdg-desktop-portal-kde|org\.kde\.kdialog|org\.kde\.systemsettings|kcmshell6)$]],
	},

	float = true,
	center = true,

	size = {
		'monitor_w*0.60',
		'monitor_h*0.65',
	},

	persistent_size = true,
})

-- PipeWire / PulseAudio mixer.

hl.window_rule({
	name = 'pavucontrol',

	match = {
		initial_class = [[^(pavucontrol|org\.pulseaudio\.pavucontrol)$]],
	},

	float = true,
	center = true,

	size = {
		'monitor_w*0.60',
		'monitor_h*0.70',
	},

	persistent_size = true,
})

-- NetworkManager connection editor.

hl.window_rule({
	name = 'network-connection-editor',

	match = {
		initial_class = '^nm-connection-editor$',
	},

	float = true,
	center = true,

	size = {
		'monitor_w*0.55',
		'monitor_h*0.65',
	},

	persistent_size = true,
})

-- BlueDevil pairing wizard.

hl.window_rule({
	name = 'bluedevil-wizard',

	match = {
		initial_class = [[^(org\.kde\.bluedevilwizard|bluedevil-wizard)$]],
	},

	float = true,
	center = true,

	size = {
		'monitor_w*0.50',
		'monitor_h*0.55',
	},
})

-- Authentication prompts must remain focused.

hl.window_rule({
	name = 'pinentry-focus',

	match = {
		class = [[^(pinentry-.*|pinentry.*|org\.gnupg\.pinentry.*)$]],
	},

	float = true,
	center = true,
	stay_focused = true,
	dim_around = true,
})

-- Zotero dialogs without affecting the main library window.

hl.window_rule({
	name = 'zotero-dialogs',

	match = {
		initial_class = '^(Zotero|zotero)$',
		initial_title = [[^(Zotero Preferences|Document Preferences|Add Citation|Add/Edit Citation|Add Note|Progress)$]],
	},

	float = true,
	center = true,
	persistent_size = true,
})
