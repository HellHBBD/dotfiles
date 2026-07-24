-- Rule load order is intentional.
--
-- 00-base:
--   global compositor behavior and compatibility fixes
--
-- 10-dialog:
--   dialogs, settings windows and authentication prompts
--
-- 20-window:
--   application-specific and content-specific behavior
--
-- 30-layer:
--   Waybar, Fuzzel, SwayNC, Wlogout and other layer-shell surfaces

require('hyprland.rules.00-base')
require('hyprland.rules.10-dialog')
require('hyprland.rules.20-window')
require('hyprland.rules.30-layer')
