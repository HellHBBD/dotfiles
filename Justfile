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

bash:
    sudo pacman -S --needed bash stow
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

nvim:
    sudo pacman -S --needed \
        neovim \
        nodejs \
        npm \
        luarocks \
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

waybar: swaync
    sudo pacman -S --needed \
        waybar \
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

# Hyprland 整合層，最後執行
hyprland: ghostty tmux wallpapers swaync waybar cliphist wlogout
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

# 完整桌面
desktop: hyprland
    @printf '%s\n' "桌面套件與設定已完成"

# 全部設定
all: bash git nvim hyprland
    @printf '%s\n' "所有 dotfiles 已完成"
