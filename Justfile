set shell := ["bash", "-euo", "pipefail", "-c"]

repo := justfile_directory()
home := env("HOME")

default:
    @just --list

# 共用 Stow 操作
stow package:
    stow \
        --dir "{{repo}}" \
        --target "{{home}}" \
        --restow \
        "{{package}}"

unstow package:
    stow \
        --dir "{{repo}}" \
        --target "{{home}}" \
        --delete \
        "{{package}}"

# 基礎設定

formatters:
    just stow formatters

system-bash:
    sudo pacman -S --needed bash stow
    if [ -e /etc/bash.bashrc ] && [ ! -L /etc/bash.bashrc ]; then \
        if [ -e /etc/bash.bashrc.pre-stow ]; then \
            printf '%s\n' '/etc/bash.bashrc.pre-stow 已存在，為避免覆蓋備份而停止' >&2; \
            exit 1; \
        fi; \
        sudo mv -- /etc/bash.bashrc /etc/bash.bashrc.pre-stow; \
    fi
    sudo stow \
        --dir "{{repo}}" \
        --target / \
        --restow \
        --no-folding \
        system-bash

# Portable UEFI boot support. This repository expects the ESP at /boot.
boot-compatibility:
    sudo sh -c 'test "$(findmnt --target /boot --noheadings --output FSTYPE)" = vfat'
    sudo pacman -S --needed \
        grub \
        efibootmgr \
        mkinitcpio \
        linux-firmware \
        amd-ucode \
        intel-ucode \
        stow
    for path in /etc/mkinitcpio.conf /etc/mkinitcpio.d/linux.preset /etc/grub.d/40_custom; do \
        if [ -e "$path" ] && [ ! -L "$path" ]; then \
            backup="$path.pre-stow"; \
            if [ -e "$backup" ]; then \
                printf '%s\\n' "$backup 已存在，為避免覆蓋備份而停止" >&2; \
                exit 1; \
            fi; \
            sudo mv -- "$path" "$backup"; \
        fi; \
    done
    sudo stow \
        --dir "{{repo}}" \
        --target / \
        --restow \
        --no-folding \
        boot-compatibility
    sudo mkinitcpio -P
    sudo grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot \
        --bootloader-id=GRUB \
        --removable \
        --recheck
    sudo grub-mkconfig -o /boot/grub/grub.cfg

bash: system-bash
    just stow bash

git:
    sudo pacman -S --needed git stow
    just stow git

ghostty:
    sudo pacman -S --needed ghostty stow
    just stow ghostty

tmux:
    sudo pacman -S --needed tmux stow
    just stow tmux

herdr:
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed herdr-bin
    if [ -e "{{home}}/.config/herdr/config.toml" ] && [ ! -L "{{home}}/.config/herdr/config.toml" ]; then \
        if [ -e "{{home}}/.config/herdr/config.toml.pre-stow" ]; then \
            printf '%s\n' '~/.config/herdr/config.toml.pre-stow 已存在，為避免覆蓋備份而停止' >&2; \
            exit 1; \
        fi; \
        mv -- "{{home}}/.config/herdr/config.toml" "{{home}}/.config/herdr/config.toml.pre-stow"; \
    fi
    mkdir -p "{{home}}/.config/herdr"
    stow \
        --dir "{{repo}}" \
        --target "{{home}}" \
        --restow \
        --no-folding \
        herdr

nvim: formatters
    sudo pacman -S --needed \
        neovim \
        nodejs \
        npm \
        luarocks \
        stylua \
        ripgrep \
        fd \
        tree-sitter-cli \
        lazygit \
        wl-clipboard \
        stow
    just stow nvim

# Hyprland 外部元件

wallpapers:
    sudo pacman -S --needed stow
    just stow wallpapers

swaync:
    sudo pacman -S --needed \
        swaync \
        libnotify \
        stow
    just stow swaync

swayosd:
    sudo pacman -S --needed \
        swayosd \
        stow
    sudo usermod --append --groups video "$USER"
    just stow swayosd

# System memory-pressure protection, managed under /etc via GNU Stow.
systemd-oomd:
    sudo stow \
        --dir "{{repo}}" \
        --target / \
        --restow \
        --no-folding \
        systemd-oomd
    sudo systemctl daemon-reload
    sudo systemctl enable --now systemd-oomd.service
    sudo systemctl set-property --runtime "user@$(id -u).service" \
        ManagedOOMSwap=kill \
        ManagedOOMMemoryPressure=kill \
        ManagedOOMMemoryPressureLimit=40% \
        ManagedOOMMemoryPressureDurationSec=20s
    sudo systemctl restart systemd-oomd.service

waybar: swaync
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed waybar-git
    sudo pacman -S --needed \
        jq \
        playerctl \
        networkmanager \
        bluez \
        bluez-utils \
        plasma-nm \
        bluedevil \
        pipewire \
        pipewire-pulse \
        wireplumber \
        pavucontrol \
        fuzzel \
        grim \
        slurp \
        hyprpicker \
        wl-clipboard \
        ttf-jetbrains-mono-nerd \
        noto-fonts-cjk \
        stow
    just stow waybar

cliphist:
    sudo pacman -S --needed \
        cliphist \
        wl-clipboard \
        fuzzel \
        stow
    just stow cliphist
    systemctl --user daemon-reload

wlogout:
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed wlogout
    sudo pacman -S --needed stow
    just stow wlogout

spotify:
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed spotify
    sudo pacman -S --needed stow
    just stow spotify

# Hyprland 整合層，最後執行
hyprland: ghostty tmux wallpapers swaync swayosd waybar cliphist wlogout
    sudo pacman -S --needed \
        hyprland \
        hyprshutdown \
        uwsm \
        hyprpaper \
        hyprlock \
        hypridle \
        hyprpolkitagent \
        polkit \
        xdg-desktop-portal \
        xdg-desktop-portal-hyprland \
        xdg-desktop-portal-gtk \
        fuzzel \
        dolphin \
        grim \
        slurp \
        hyprpicker \
        brightnessctl \
        python-gobject \
        gtk4 \
        libadwaita \
        fcitx5 \
        fcitx5-gtk \
        fcitx5-qt \
        fcitx5-chewing \
        fcitx5-configtool \
        ttf-jetbrains-mono-nerd \
        noto-fonts-cjk \
        noto-fonts-emoji \
        stow

    sudo systemctl enable --now NetworkManager.service
    sudo systemctl enable --now bluetooth.service

    systemctl --user daemon-reload
    just stow hyprland

# 登入管理員
login-manager:
    sudo pacman -S --needed greetd greetd-tuigreet

# 完整桌面
desktop: login-manager hyprland
    @printf '%s\n' "桌面套件與設定已完成"

# 全部設定
all: bash git nvim hyprland
    @printf '%s\n' "所有 dotfiles 已完成"
