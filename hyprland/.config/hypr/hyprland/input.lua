-- Keyboard, pointer, touchpad and gesture configuration.

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "ctrl:nocaps",
        kb_rules = "",

        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,

        follow_mouse = 1,
        sensitivity = 0.0,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            tap_to_click = true,
            tap_and_drag = true,
            scroll_factor = 0.5,
        },
    },

    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    },
})

-- Three-finger swipe: move the active window.
hl.gesture({
    fingers = 3,
    direction = "swipe",
    action = "move",
})

-- Four-finger horizontal swipe: switch workspace.
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace",
})

-- Four-finger pinch: toggle floating state.
hl.gesture({
    fingers = 4,
    direction = "pinch",
    action = "float",
})
