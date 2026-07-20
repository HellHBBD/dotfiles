-- Application and content-specific window rules.

-- Browser Picture-in-Picture windows.

hl.window_rule({
    name = "picture-in-picture",

    match = {
        title = "^(Picture-in-Picture|Picture in picture|Picture in Picture)$",
    },

    float = true,
    pin = true,
    keep_aspect_ratio = true,

    size = {
        "monitor_w*0.25",
        "monitor_h*0.25",
    },

    move = {
        "monitor_w-window_w-20",
        "monitor_h-window_h-60",
    },

    no_initial_focus = true,
})

-- Prevent fullscreen video playback from triggering idle actions.

hl.window_rule({
    name = "fullscreen-video-idle-inhibit",

    match = {
        content = "video",
        fullscreen = true,
    },

    idle_inhibit = "fullscreen",
})

-- Steam game windows.

hl.window_rule({
    name = "steam-games",

    match = {
        class = "^steam_app_.*$",
    },

    content = "game",
    immediate = true,
    idle_inhibit = "fullscreen",
})

-- Minecraft instances may expose different class names depending on the
-- launcher and Java runtime.

hl.window_rule({
    name = "minecraft",

    match = {
        class = "^(Minecraft.*|minecraft.*|java.*Minecraft.*)$",
    },

    content = "game",
    immediate = true,
    idle_inhibit = "fullscreen",
})

-- Wine and Proton game executables.

hl.window_rule({
    name = "wine-executables",

    match = {
        class = [[.*\.exe]],
    },

    content = "game",
    immediate = true,
    idle_inhibit = "fullscreen",
})

-- Games should be able to request focus when launched.

hl.window_rule({
    name = "games-focus-on-activate",

    match = {
        content = "game",
    },

    focus_on_activate = true,
})
