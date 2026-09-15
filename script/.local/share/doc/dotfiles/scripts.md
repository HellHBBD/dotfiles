# Personal Scripts

`~/.local/bin` contains direct user commands. Private helpers are installed
under `~/.local/libexec/dotfiles` and must not be added to `PATH`.

## guard-run

`guard-run` runs build or installation commands in a low-priority systemd user
service from the current directory. It limits the default build parallelism to
eight jobs and protects the desktop from memory and swap exhaustion. If the
scope encounters an out-of-memory event, systemd terminates the scope rather
than leaving its processes running.

```sh
guard-run -- makepkg -si
guard-run -- yay -S webkit2gtk
guard-run --jobs 4 --memory-max 10G -- cargo build --release
guard-run -- CFLAGS='-O2 -pipe' DEBUG=1 cargo build
guard-run -- bash -c 'make && ./test.sh | tee result.log'
```

The defaults are `--jobs 8`, `--nice 10`, `--cpu-weight 25`,
`--cpu-quota 1200%`, `--io-weight 50`, `--memory-high 10G`,
`--memory-max 12G`, and `--swap-max 2G`. After `--`, leading `NAME=VALUE`
arguments are passed only to that command; the first non-assignment argument
starts the command. `guard-run` options must appear before `--`. Commands using
pipes, redirections, or `&&` must be passed through a shell, for example:

```sh
guard-run -- bash -c 'make && ./test.sh | tee result.log'
```

Running `guard-run` without arguments displays help. Use `guard-run --help` for
all override options.

## Manual Notes

The retired `cheat_sheet.sh` contained these privileged fail2ban examples:

```sh
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip 192.168.1.100
sudo fail2ban-client reload sshd
```
