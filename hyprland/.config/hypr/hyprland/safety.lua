-- Permanent safety keybinds.
--
-- These must remain usable even when optional desktop components fail.

local terminal_command = [[
for terminal in ghostty foot kitty alacritty; do
    if command -v "$terminal" >/dev/null 2>&1; then
        exec "$terminal"
    fi
done

notify-send "Hyprland" "No supported terminal was found"
]]

local exit_session_command = [[
if command -v uwsm >/dev/null 2>&1 &&
    systemctl --user is-active --quiet 'wayland-wm@*.service'; then
    exec uwsm stop
elif command -v hyprshutdown >/dev/null 2>&1; then
    exec hyprshutdown
else
    hyprctl dispatch 'hl.dsp.exit()'
fi
]]

hl.bind(
    "SUPER + Return",
    hl.dsp.exec_cmd(terminal_command),
    { description = "Open terminal" }
)

hl.bind(
    "SUPER + Q",
    hl.dsp.window.close(),
    { description = "Close active window" }
)

hl.bind(
    "SUPER + SHIFT + M",
    hl.dsp.exec_cmd(exit_session_command),
    { description = "Exit graphical session" }
)

hl.bind(
    "SUPER + ALT + Space",
    hl.dsp.window.float({ action = "toggle" }),
    { description = "Toggle floating" }
)

hl.bind(
    "SUPER + F",
    hl.dsp.window.fullscreen({
        mode = "fullscreen",
        action = "toggle",
    }),
    { description = "Toggle fullscreen" }
)

hl.bind(
    "SUPER + Left",
    hl.dsp.focus({ direction = "l" }),
    { description = "Focus left" }
)

hl.bind(
    "SUPER + Right",
    hl.dsp.focus({ direction = "r" }),
    { description = "Focus right" }
)

hl.bind(
    "SUPER + Up",
    hl.dsp.focus({ direction = "u" }),
    { description = "Focus up" }
)

hl.bind(
    "SUPER + Down",
    hl.dsp.focus({ direction = "d" }),
    { description = "Focus down" }
)

hl.bind(
    "SUPER + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    "SUPER + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)
