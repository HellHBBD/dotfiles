-- Hyprland configuration entry point.
--
-- Load order matters:
--   1. minimal  - required configuration for a usable session
--   2. optional - desktop services, appearance, rules and keybinds
--   3. custom   - machine-specific overrides loaded last

require("hyprland.minimal")

-- Enable after the base session passes Linux bring-up.
-- require("hyprland.optional")

require("custom.init")
