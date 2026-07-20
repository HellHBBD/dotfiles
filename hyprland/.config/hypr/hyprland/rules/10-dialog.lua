-- Dialog and utility window rules.

hl.window_rule({
    name = "modal-dialogs",

    match = {
        modal = true,
    },

    float = true,
    center = true,
    dim_around = true,
})

-- Generic file chooser titles.
--
-- Class matching is intentionally avoided here because GTK and Qt portal
-- implementations may use different classes while keeping familiar titles.

hl.window_rule({
    name = "file-chooser-dialogs",

    match = {
        title = "^(Open File|Select a File|Open Folder|Select Folder|Save As|File Upload|Choose wallpaper|.* wants to (open|save).*)$",
    },

    float = true,
    center = true,

    size = {
        "monitor_w*0.60",
        "monitor_h*0.65",
    },

    persistent_size = true,
})

-- KDE portal, KDialog and control-module windows.

hl.window_rule({
    name = "kde-settings-and-portals",

    match = {
        class = "^(xdg-desktop-portal-kde|org\\.kde\\.kdialog|org\\.kde\\.systemsettings|kcmshell6)$",
    },

    float = true,
    center = true,

    size = {
        "monitor_w*0.60",
        "monitor_h*0.65",
    },

    persistent_size = true,
})

-- Audio settings.

hl.window_rule({
    name = "pavucontrol",

    match = {
        class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$",
    },

    float = true,
    center = true,

    size = {
        "monitor_w*0.60",
        "monitor_h*0.70",
    },

    persistent_size = true,
})

-- NetworkManager connection editor.

hl.window_rule({
    name = "network-connection-editor",

    match = {
        class = "^(nm-connection-editor)$",
    },

    float = true,
    center = true,

    size = {
        "monitor_w*0.55",
        "monitor_h*0.65",
    },

    persistent_size = true,
})

-- KDE Bluetooth setup wizard.

hl.window_rule({
    name = "bluedevil-wizard",

    match = {
        class = "^(org\\.kde\\.bluedevilwizard|bluedevil-wizard)$",
    },

    float = true,
    center = true,

    size = {
        "monitor_w*0.50",
        "monitor_h*0.55",
    },
})

-- Authentication prompts must remain focused.

hl.window_rule({
    name = "pinentry-focus",

    match = {
        class = "^(pinentry.*|org\\.gnupg\\.pinentry.*)$",
    },

    float = true,
    center = true,
    stay_focused = true,
    dim_around = true,
})

-- Zotero dialogs without affecting the main library window.

hl.window_rule({
    name = "zotero-dialogs",

    match = {
        class = "^(Zotero|zotero)$",
        title = "^(Zotero Preferences|Document Preferences|Add Citation|Add/Edit Citation|Add Note|Progress)$",
    },

    float = true,
    center = true,
    persistent_size = true,
})
