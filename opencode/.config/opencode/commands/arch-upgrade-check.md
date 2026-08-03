---
description: Check Arch Linux upgrade readiness and post-upgrade desktop health without changing the system.
agent: plan
subtask: false
---

# Arch Upgrade Check

Interpret `$ARGUMENTS` as exactly one optional mode: `quick`, `pre`, `post`,
`aur`, `full`, or `help`. With no argument, use `pre`. Reject any other input
with the usage below; never treat arguments as shell input.

```text
/arch-upgrade-check [quick|pre|post|aur|full|help]
```

This is a read-only diagnostic command for this Arch Linux desktop:

```text
Display manager: greetd + tuigreet
Session manager: UWSM
Compositor: Hyprland
GPU: NVIDIA open DKMS
Notifications: SwayNC
Portal: xdg-desktop-portal-hyprland
Wallpaper: hyprpaper
Audio: PipeWire + WirePlumber
Network: NetworkManager
```

## Safety Boundary

Run only read-only, non-privileged diagnostics. Never execute or construct an
operation that changes system, package, service, boot, user, Git, or
configuration state. In particular, never run `sudo`, `sudoedit`, `doas`,
`su`, `pkexec`, `run0`, package installation/removal/upgrade commands,
`systemctl start|stop|restart|enable|disable|reset-failed`, `reboot`, logout
commands, `mkinitcpio`, `grub-mkconfig`, `grub-install`, `stow`, `just`, or
any command that writes files.

When an action or privileged diagnostic is needed, print one exact command in
a fenced `bash` block, explain why it is needed, and wait for the user to run
it and provide its complete output and exit status. Do not assume it succeeded
or continue past its required evidence. Do not suggest `--noconfirm`,
`pacman -Sy`, partial upgrades, or automatic repairs.

You may run ordinary read-only commands such as `pacman -Q`, `pacman -Dk`,
`checkupdates`, `yay -Qua`, `findmnt`, `df`, `dkms status`, `modinfo`,
`systemctl is-*`, `journalctl`, and `coredumpctl`. Do not run any command that
could prompt for elevation or mutate state. If a read-only check cannot run
without elevation, show it for the user instead.

Treat command exit statuses correctly. In particular, `checkupdates` exits 2
when no updates are available, and `systemctl is-enabled` can return nonzero
for a disabled unit. Do not infer a package transaction outcome from a search
for words such as `error`; require the user's full transaction output and its
exit status.

## Output Contract

For every mode, end with exactly these sections in this order:

```text
1. Overall
2. Reboot gate
3. Blocking failures
4. Warnings
5. Passed checks
6. Manual tests
7. Suggested commands
```

Use only `PASS`, `WARN`, and `FAIL` statuses. Only a `FAIL` may produce `DO
NOT REBOOT`. Every `WARN` must state its practical impact and what evidence
would turn it into `PASS` or `FAIL`. Never claim a manually suggested command
was run by the user unless they supplied its output.

When mode is `pre`, set the final reboot gate to exactly one of:

```text
READY TO REBOOT
DO NOT REBOOT
NOT YET ASSESSED
```

For other modes, set the reboot gate to `NOT ASSESSED` unless the evidence is
directly sufficient to make a reboot decision.

## Shared Interpretation Rules

Do not treat historical errors as a current failure without correlating all of:

- Current service state and relevant process state.
- The error timestamp and boot/session in which it occurred.
- Whether it occurred during compositor shutdown or logout.
- Whether the affected feature currently works.

The following are normally `WARN`, not standalone failures, when current
services and the affected feature are healthy:

- D-Bus duplicate activation-name messages.
- `integrity: Problem loading X.509 certificate -65` while NVIDIA works.
- A Bluetooth initialization warning while Bluetooth works.
- An optional masked service.
- A portal failure only after the Wayland compositor exited.
- A wallpaper-process coredump only during compositor shutdown.
- A stale `not-found failed` unit from a removed package.

Do not permanently whitelist any message. Escalate it to `FAIL` if it recurs
in the current session, affects a required service, or the relevant feature is
not working.

This repository uses UKIs, not standalone initramfs files. Its expected boot
artifacts are:

```text
/boot/vmlinuz-linux
/boot/EFI/Linux/arch-linux.efi
/boot/EFI/Linux/arch-linux-fallback.efi
```

Do not require `/boot/initramfs-linux.img` or
`/boot/initramfs-linux-fallback.img`.

## Mode: `quick`

Run the smallest useful current-session health check:

- `uname -r`, installed `linux` and `linux-headers` versions, and `nvidia-smi`.
- Loaded NVIDIA modules.
- System and user failed units.
- `greetd` enabled/active and LightDM disabled.
- SwayNC service state and exactly one `swaync` process.
- Both portal services active.
- Recent coredumps from the current boot when available.

If a required command is absent, report `WARN` with its package or diagnostic
requirement; do not install it.

## Mode: `pre`

First perform upgrade readiness checks:

- Show official updates with `checkupdates` and AUR updates with `yay -Qua`.
- If `checkupdates` is absent, show the command needed to install
  `pacman-contrib` and wait for user-provided evidence before retrying.
- Mark updates to kernel, headers, systemd, glibc, gcc, mesa, wayland,
  NVIDIA, Hyprland, Aquamarine, greetd, portals, PipeWire, WirePlumber,
  NetworkManager, mkinitcpio, GRUB, firmware, and CPU microcode as high risk.
- Fetch and summarize current Arch Linux News if web access is available;
  otherwise provide the official News URL and require the user to confirm
  they checked it before recommending an upgrade.
- Check `/boot` mounting and free space with `findmnt` and `df`.
- Run `pacman -Dk`, check for `/var/lib/pacman/db.lck`, and check for running
  `pacman`, `yay`, or `makepkg` processes.
- Check `greetd`, LightDM, and `display-manager.service` without changing
  them.

Before the official upgrade, suggest backup commands only. The EFI backup is
privileged and must be shown, never run. Then show the exact full-upgrade
command below and wait for complete output plus the exit status:

```bash
sudo pacman -Syu
printf '\nexit=%s\n' "$?"
```

After the user provides successful upgrade evidence, perform the reboot gate:

- Recheck package-manager processes and the pacman lock.
- Check that `linux` and `linux-headers` are installed at matching versions.
- Derive the installed kernel release from `pacman -Qql linux` and verify it
  is nonempty.
- Check `dkms status` for NVIDIA installed against that kernel.
- Check `modinfo -k <new-kernel> nvidia`.
- Verify the three expected boot artifacts exist and are nonempty.
- Read the `.uname` section of both UKIs with `objcopy` when available and
  verify it matches the installed kernel release.

If an artifact or UKI section cannot be inspected without elevation, show one
exact diagnostic command and wait for the result. Do not show a reboot command
unless every reboot-gate condition has `PASS`.

## Mode: `post`

Run the post-reboot desktop checks:

- Verify `uname -r`, installed kernel versions, `nvidia-smi`, and loaded
  NVIDIA modules.
- Check system and user failed units, then inspect relevant failed units before
  classifying them.
- Check greetd is active and enabled, LightDM is disabled, and the display
  manager resolves to greetd where that link exists.
- Verify `XDG_SESSION_TYPE`, `XDG_CURRENT_DESKTOP`, `hyprctl version`, and
  active UWSM/Hyprland session evidence.
- Check SwayNC is active and has one process.
- Check both `xdg-desktop-portal.service` and
  `xdg-desktop-portal-hyprland.service`.
- Check PipeWire, PipeWire Pulse, WirePlumber, NetworkManager, Bluetooth,
  Waybar, and hyprpaper.
- Review `journalctl -b -p err --no-pager`, its user-session equivalent when
  available, and `coredumpctl list --since boot`.

Request user confirmation for notification, volume and brightness keys,
speaker, microphone, headset switching, Wi-Fi, Bluetooth, browser/Discord
screen sharing, OBS PipeWire capture, and Flatpak file selection. Then remind
the user to log out, confirm tuigreet returns, and log in again. Do not execute
the logout command.

## Mode: `aur`

Run only `yay -Qua` and classify each update as one of:

- General application.
- System service or driver.
- Electron runtime or WebKitGTK.
- Hyprland, desktop shell, portal, or graphics library.
- `-git` package.
- Large compilation workload.

State which updates are reasonable to batch and which should be isolated.
When an update is appropriate, show but do not execute either:

```bash
yay -Sua
```

or:

```bash
env MAKEFLAGS="-j2" CMAKE_BUILD_PARALLEL_LEVEL=2 CARGO_BUILD_JOBS=2 yay -Sua
```

After user-provided completion output, rerun `yay -Qua` and check failed
units. State whether a reboot or relogin is advisable based on the actual
updated packages.

## Mode: `full`

Perform the complete current-system health review: all `quick` and `post`
checks, plus audio, network, Bluetooth, wallpaper, and current-boot logs. Do
not ask the user to update packages and do not assess pre-upgrade readiness
unless they explicitly invoke `pre`.

## Mode: `help`

Do not run diagnostics. Print the supported modes, the safety boundary, and a
one-line purpose for each mode.
