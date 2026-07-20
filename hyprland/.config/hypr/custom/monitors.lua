-- Monitor configuration for the current laptop.
--
-- Start with the display's preferred mode. After reinstalling, verify the
-- exact mode with:
--
--     hyprctl monitors all
--
-- The previous installation appeared to use:
--
--     1920x1080@165.01
--
-- Do not force that mode until the new installation confirms it.

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

-- After verification, the rule above may be changed to:
--
-- hl.monitor({
--     output = "eDP-1",
--     mode = "1920x1080@165.01",
--     position = "0x0",
--     scale = 1,
-- })
