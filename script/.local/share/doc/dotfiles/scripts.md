# Personal Scripts

`~/.local/bin` contains direct user commands. Private helpers are installed
under `~/.local/libexec/dotfiles` and must not be added to `PATH`.

## Manual Notes

The retired `cheat_sheet.sh` contained these privileged fail2ban examples:

```sh
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip 192.168.1.100
sudo fail2ban-client reload sshd
```
