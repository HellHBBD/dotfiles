# Personal Scripts

`~/.local/bin` contains direct user commands. Private helpers are installed
under `~/.local/libexec/dotfiles` and must not be added to `PATH`.

## guard-run

`guard-run` runs build or installation commands in a low-priority systemd user
service. It limits the default build parallelism to two jobs and protects the
desktop from memory and swap exhaustion. If the scope encounters an out-of-
memory event, systemd terminates the scope rather than leaving its processes
running.

```sh
guard-run -- makepkg -si
guard-run -- yay -S webkit2gtk
guard-run --jobs 4 --memory-max 10G -- cargo build --release
```

The defaults are `--jobs 2`, `--nice 10`, `--cpu-weight 10`,
`--memory-high 6G`, `--memory-max 8G`, and `--swap-max 1G`. Use
`guard-run --help` for all override options. Commands must follow `--`.

## Manual Notes

The retired `cheat_sheet.sh` contained these privileged fail2ban examples:

```sh
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip 192.168.1.100
sudo fail2ban-client reload sshd
```
