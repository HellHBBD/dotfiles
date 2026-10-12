# Runtime Display Switching

`Super + Shift + P` runs `hyprland/.config/hypr/scripts/display-mode.sh`.
It discovers connected outputs through `hyprctl -j monitors all`; it does not
require `eDP-1` or restrict the target to HDMI.

## Selection and actions

- Prefer an enabled independent internal panel (`eDP-*`, `LVDS-*`, `DSI-*`) as
  source; otherwise use the focused independent output, then the first by ID.
- With only one connected output, notify that no switching is needed and exit.
- With several possible targets, select by connector and display description.
  Connected but disabled outputs are included and labelled.
- Mirror the source to the target, extend without moving a workspace, extend and
  move the current workspace, move an existing numbered workspace, or disable
  only the selected target. Other connected outputs are left alone.
- Use “更換來源螢幕” to choose another enabled independent source. Escape cancels.

Before control operations, recheck that the selected source remains enabled and
independent and that the target remains connected. Refuse to mirror/disable an
output serving as another mirror's source. This guards stale menu selections; it
cannot make physical unplugging during an operation atomic.

For active targets, retain the current advertised mode/refresh, scale and rotation.
For a previously mirrored/disabled target, prefer settings saved by this script;
otherwise use its reported scale/rotation and preferred mode. Newly activated or
unmirrored outputs extend with `auto-right`; active extended targets keep their
position. Color/HDR and advanced monitor settings are not covered by these saved
settings. Explicit machine-specific baseline monitor rules remain in
`custom/monitors.lua`.

## Workspaces and hotplug

`$XDG_RUNTIME_DIR/hypr-display-mode.json` stores version 2 records keyed by target,
with source, numbered workspaces and mode/scale/rotation/position. Updates are
atomic and switching/repair operations use a short bounded `flock` lock. The old
workspace array is recognized only for its original `eDP-1` → `HDMI-A-1` pair.

Before mirroring/disabling, move target workspaces to the source. On extension,
restore only recorded workspaces which still exist on that recorded source;
do not steal workspaces subsequently moved to a third output or create missing
workspaces. Per-output records survive operations on other targets.

Every monitor-added event schedules `--repair-mirror` after 500 ms. Repair obtains
actual mirror/source relationships, migrates any wrongly restored workspaces, and
is silent for non-mirror outputs. It does not change monitor modes or need fuzzel.

The existing audio policy is specific to the laptop's NVIDIA HDMI connector. Only
the original `eDP-1`/`HDMI-A-1` pair invokes it; desktop/DP switching leaves audio
selection to the existing session policy. This change does not generalize that
separate audio policy.

## Verification

```sh
bash -n hyprland/.config/hypr/scripts/display-mode.sh
shellcheck hyprland/.config/hypr/scripts/display-mode.sh
shfmt -d -i 4 hyprland/.config/hypr/scripts/display-mode.sh
guard-run -- timeout --signal=TERM --kill-after=10s 120s python3 tools/test-display-mode.py
Hyprland --verify-config --config "$HOME/.config/hypr/hyprland.lua"
```

The test harness replaces hyprctl, fuzzel, notifications and the audio policy with
local mocks. It never contacts the running compositor or changes real monitors.
Real multi-monitor mode transitions, mirror compatibility and hotplug timing
still require hardware testing. Saving the active Lua config can automatically
reload it; manual reload and live switching require separate approval.
