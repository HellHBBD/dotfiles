-- Generic monitor fallback.
--
-- This rule applies to displays that do not have a more specific rule.
-- Machine-specific monitor rules are loaded later from custom/monitors.lua.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})
