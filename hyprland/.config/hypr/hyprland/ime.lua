-- Input method integration.
--
-- Fcitx 5 is treated as a basic session component so Chinese input remains
-- available even while the optional desktop layer is disabled.

-- Direct Hyprland fallback.
-- UWSM sessions receive the same values from ~/.config/uwsm/env.
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_IM_MODULES", "wayland;fcitx;ibus")

hl.on("hyprland.start", function()
    hl.exec_cmd([[
if ! command -v fcitx5 >/dev/null 2>&1; then
    exit 0
fi

if pgrep -x fcitx5 >/dev/null 2>&1; then
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 &&
   systemctl --user is-active --quiet 'wayland-session@*.target'; then
    exec uwsm app -- fcitx5 --replace
else
    exec fcitx5 --replace
fi
]])
end)
