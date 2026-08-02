-- Environment variables required by the Hyprland session.
--
-- Keep this file minimal. Toolkit themes, input methods and GPU-specific
-- variables will be added later only when their dependencies are known.

hl.env('XCURSOR_SIZE', '24')
hl.env('HYPRCURSOR_SIZE', '24')
hl.env('ELECTRON_OZONE_PLATFORM_HINT', 'wayland')
hl.env('SAL_USE_VCLPLUGIN', 'gtk3')
