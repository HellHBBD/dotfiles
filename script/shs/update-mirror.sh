sudo reflector --sort rate --age 12 --latest 10 --download-timeout 5 --threads 20 --fastest 5 --save /etc/pacman.d/mirrorlist
