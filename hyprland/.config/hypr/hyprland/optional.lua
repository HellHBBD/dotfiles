-- Optional desktop layer.
--
-- Load order:
--   1. shared compositor behavior
--   2. animation definitions
--   3. active visual preset
--   4. workspace behavior
--   5. autostart
--   6. full keybinds
--   7. window and layer rules

require("hyprland.general")
require("hyprland.animations")
require("presets.current")

require("hyprland.workspaces")
require("hyprland.execs")
require("hyprland.keybinds")
require("hyprland.rules.init")
