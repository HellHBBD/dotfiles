# Legacy Desktop Configuration Archive

This branch preserves the retired desktop configuration that was removed from
`Desktop` on 2026-07-30. It remains available for reference or recovery.

Archived paths:

- `dots-hyprland/`: previous Hyprland `.conf` configuration
- `hyprland/.config/hypr/hyprland.conf`: generated Hyprland example config
- `i3/`, `picom/`, `polybar/`, `rofi/`: previous X11/i3 desktop stack
- `kitty/`: unused Kitty default configuration
- `LazyVim/`: unused alternate Neovim configuration
- `launch.sh`: previous manual symlink installer

To restore a path to `Desktop`, check it out from this branch, for example:

```sh
git checkout i3/legacy-configs-20260730 -- i3
```
