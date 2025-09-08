# fail2ban status
sudo fail2ban-client status sshd
# fail2ban unban
sudo fail2ban-client set sshd unbanip 192.168.1.100
# fail2ban unban all
sudo fail2ban-client reload sshd
