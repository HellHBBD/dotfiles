---
name: core-hyprland-config
description: Use when inspecting, modifying, debugging, or validating Hyprland configuration, keybinds, monitors, window rules, workspaces, animations, devices, or hyprctl behavior.
---

# Hyprland Configuration

Use the installed Hyprland version and its matching official Wiki as the source
of truth. Do not infer current syntax from old configuration examples.

## Scope

- Use for Hyprland configuration files, generated configuration modules, and
  related `hyprctl` diagnostics.
- Do not use for installing Hyprland, Hyprland plugins, third-party scripts, or
  unrelated Wayland applications unless the user explicitly asks.
- Do not add plugins, package dependencies, or execute downloaded scripts
  without explicit user approval.

## Discover Before Editing

1. Read repository instructions and inspect the existing configuration layout.
2. Determine the installed version with `hyprctl version` or `Hyprland --version`.
3. Select the matching documentation version:
   - Hyprland 0.55 and later: `https://wiki.hypr.land/<version>/`
   - Hyprland 0.54 and earlier: `https://wiki.hypr.land/0.54.0/`
   - If no local binary is available, ask for the target version before writing
     version-sensitive syntax.
4. Identify the actual entry file and include graph before editing:
   - Lua configurations normally start at `$XDG_CONFIG_HOME/hypr/hyprland.lua`
     and use `require()`.
   - Legacy Hyprlang configurations normally start at
     `$XDG_CONFIG_HOME/hypr/hyprland.conf` and use `source =`.
   - Follow local modules, overrides, generated files, and load order. Edit the
     narrowest owned source file, not a derived output.
5. For hardware- or window-specific work, inspect only the required state:
   - `hyprctl -j monitors all` for outputs and modes.
   - `hyprctl -j devices` for input device names.
   - `hyprctl -j clients` for window class, title, and other rule match data.
   - `hyprctl -j binds`, `hyprctl -j workspaces`, or `hyprctl -j activeworkspace`
     when relevant.

## Version Rules

- Hyprland 0.55 introduced Lua configuration and deprecated Hyprlang. Prefer
  Lua APIs and current Wiki examples for 0.55+ installations.
- Retain an existing legacy Hyprlang layout when supporting 0.54 or earlier;
  do not migrate a working configuration merely to make it look modern.
- Do not mix `hl.*` Lua API calls with Hyprlang assignment syntax in the same
  configuration path.
- Check the exact official documentation page for changed APIs, option names,
  dispatchers, bind syntax, and window-rule match properties.

## Safe Changes

- Make the smallest change that satisfies the request and preserve the
  project's formatting, module boundaries, comments, and override order.
- Keep essential recovery paths available. Do not remove the user's confirmed
  terminal, close-window, launcher, or exit-session keybind without providing
  an equivalent replacement.
- Treat monitor, input, environment, autostart, GPU, session-manager, and
  plugin changes as high risk. State the affected hardware or process and
  inspect the actual runtime identifier before applying a rule.
- Use exact client data from `hyprctl -j clients` before creating a
  class/title-based window rule. Prefer narrow regular expressions.
- Avoid repetitive `hyprctl` calls in scripts. `hyprctl` requests are
  synchronous; use `--batch` for multiple control operations when appropriate.

## Live-Session Behavior

Saving an active Hyprland configuration can automatically reload it. Before
editing a configuration that the running session uses, tell the user that the
change may take effect immediately and that a faulty config can disrupt the
desktop.

- Do not claim that saving an active configuration leaves it unapplied.
- Do not run `hyprctl reload` by default.
- After successful validation, ask before manually running `hyprctl reload`.
- If the user approves, prefer `hyprctl reload config-only` when monitor
  reconfiguration is not needed; otherwise use `hyprctl reload`.
- After a reload or automatic live reload, run `hyprctl configerrors` and
  inspect the state affected by the change.

## Validation

1. Review the diff and check every changed path against its entry-file load
   graph.
2. When the Hyprland binary is available, validate the entry file without
   starting a session:

   ```sh
   Hyprland --verify-config --config <entry-file>
   ```

3. For Lua files, `luac -p <file>` may catch basic Lua syntax errors, but it
   does not replace `Hyprland --verify-config` because `hl.*` APIs and
   `require()` behavior are Hyprland-specific.
4. Do not reload when verification fails. Report the complete error, correct
   the source, and validate again.
5. If live reload is approved or has occurred automatically, run:

   ```sh
   hyprctl configerrors
   ```

6. Verify the specific intended result: monitor state, bind registration,
   client rule match, workspace behavior, or option value. Do not report
   success from command exit status alone.

## Troubleshooting

- Start with `hyprctl configerrors` for parsing and runtime config errors.
- Use `hyprctl rollinglog` only when configuration errors or session behavior
  require compositor logs.
- For a broken Lua configuration, isolate the failing module and check the
  entry-file load order. `require()` scopes modules, but a missing module can
  still stop the caller.
- Use a minimal test configuration with `Hyprland --config <file>` only when
  the user explicitly asks to start a separate test session.
