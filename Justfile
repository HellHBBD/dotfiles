set shell := ["bash", "-euo", "pipefail", "-c"]

repo := justfile_directory()
home := env("HOME")

# 顯示所有可用 Recipe 與用途
default:
    @just --list

# 建立或更新指定 Stow 套件的符號連結
stow package:
    stow \
        --dir "{{ repo }}" \
        --target "{{ home }}" \
        --restow \
        "{{ package }}"

# 移除指定 Stow 套件的符號連結
unstow package:
    stow \
        --dir "{{ repo }}" \
        --target "{{ home }}" \
        --delete \
        "{{ package }}"

# 基礎設定

# 建立共用格式化工具設定的 Stow 符號連結
formatters:
    just stow formatters

# 建立 OpenCode 全域 commands 的 Stow 符號連結，不接管既有設定目錄
opencode:
    stow \
        --dir "{{ repo }}/opencode/.config/opencode" \
        --target "{{ home }}/.config/opencode" \
        --restow \
        --no-folding \
        commands

# 格式化儲存庫內所有支援的檔案
format:
    stylua $(git ls-files '*.lua')
    ruff format $(git ls-files '*.py')
    shfmt -w $(git ls-files '*.sh' 'bash/.bash*' 'system-bash/etc/bash.bashrc' 'spotify/.local/bin/spotify-wayland' 'hyprland/.config/uwsm/env' 'boot-compatibility/etc/grub.d/*' 'boot-compatibility/etc/mkinitcpio.d/*' 'extra/.xinitrc')
    prettier --write $(git ls-files '*.json' '*.jsonc' '*.css' '*.md')
    taplo format $(git ls-files '*.toml')
    just --fmt

# 檢查格式化設定與檔案格式，不修改檔案
format-check:
    test "$(cat stylua.toml)" = "$(cat formatters/.config/stylua/stylua.toml)"
    test "$(cat .editorconfig)" = "$(cat formatters/.editorconfig)"
    test "$(cat .prettierrc.json)" = "$(cat formatters/.config/prettier/config.json)"
    test "$(cat pyproject.toml)" = "$(cat formatters/.config/ruff/pyproject.toml)"
    test "$(cat taplo.toml)" = "$(cat formatters/.config/taplo/taplo.toml)"
    stylua --check $(git ls-files '*.lua')
    ruff format --check $(git ls-files '*.py')
    shfmt -d $(git ls-files '*.sh' 'bash/.bash*' 'system-bash/etc/bash.bashrc' 'spotify/.local/bin/spotify-wayland' 'hyprland/.config/uwsm/env' 'boot-compatibility/etc/grub.d/*' 'boot-compatibility/etc/mkinitcpio.d/*' 'extra/.xinitrc')
    prettier --check $(git ls-files '*.json' '*.jsonc' '*.css' '*.md')
    taplo format --check $(git ls-files '*.toml')
    just --fmt --check

# 備份並套用 `/etc` 下的系統 Bash 設定
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
        --dir "{{ repo }}" \
        --target / \
        --restow \
        --no-folding \
        system-bash

# 啟用繁體中文 locale 並以 Stow 管理系統預設語言
system-locale:
    sudo -v
    if [ -e /etc/locale.conf ] && [ ! -L /etc/locale.conf ] && [ -e /etc/locale.conf.pre-stow ]; then \
        printf '%s\n' '/etc/locale.conf.pre-stow 已存在，為避免覆蓋備份而停止' >&2; \
        exit 1; \
    fi
    if ! sudo grep -Eq '^[[:space:]]*zh_TW\.UTF-8[[:space:]]+UTF-8([[:space:]]|$)' /etc/locale.gen; then \
        if sudo grep -Eq '^[[:space:]]*#[[:space:]]*zh_TW\.UTF-8[[:space:]]+UTF-8([[:space:]]|$)' /etc/locale.gen; then \
            sudo sed -i -E 's@^[[:space:]]*#[[:space:]]*zh_TW\.UTF-8[[:space:]]+UTF-8([[:space:]]|$)@zh_TW.UTF-8 UTF-8@' /etc/locale.gen; \
        else \
            printf '%s\n' '找不到 zh_TW.UTF-8 UTF-8 locale 定義，停止作業' >&2; \
            exit 1; \
        fi; \
    fi
    if [ -e /etc/locale.conf ] && [ ! -L /etc/locale.conf ]; then \
        if [ -e /etc/locale.conf.pre-stow ]; then \
            printf '%s\n' '/etc/locale.conf.pre-stow 已存在，為避免覆蓋備份而停止' >&2; \
            exit 1; \
        fi; \
        sudo mv -- /etc/locale.conf /etc/locale.conf.pre-stow; \
    fi
    sudo stow \
        --dir "{{ repo }}" \
        --target / \
        --restow \
        --no-folding \
        system-locale
    sudo locale-gen

# 建立一般與 fallback UKI、GRUB removable loader 等可攜式 UEFI 開機環境
boot-compatibility:
    sudo sh -c 'test "$(findmnt --target /boot --noheadings --output FSTYPE)" = vfat'
    sudo pacman -S --needed \
        grub \
        efibootmgr \
        mkinitcpio \
        linux-firmware \
        sof-firmware \
        alsa-firmware \
        wireless-regdb \
        amd-ucode \
        intel-ucode \
        stow
    if [ -L /etc/grub.d/40_custom ]; then \
        target="$(readlink /etc/grub.d/40_custom)"; \
        case "$target" in \
            *boot-compatibility/etc/grub.d/40_custom) \
                test -e /etc/grub.d/40_custom.pre-stow || { \
                    printf '%s\n' '找不到 /etc/grub.d/40_custom.pre-stow，拒絕移除目前自訂 entry' >&2; \
                    exit 1; \
                }; \
                sudo rm -- /etc/grub.d/40_custom; \
                sudo mv -- /etc/grub.d/40_custom.pre-stow /etc/grub.d/40_custom ;; \
        esac; \
    fi
    for path in /etc/mkinitcpio.conf /etc/mkinitcpio.d/linux.preset /etc/grub.d/15_uki /etc/default/grub.d/50-boot-compatibility.cfg; do \
        if [ -e "$path" ] && [ ! -L "$path" ]; then \
            backup="$path.pre-stow"; \
            if [ -e "$backup" ]; then \
                printf '%s\\n' "$backup 已存在，為避免覆蓋備份而停止" >&2; \
                exit 1; \
            fi; \
            sudo mv -- "$path" "$backup"; \
            case "$path" in \
                /etc/grub.d/15_uki) sudo chmod a-x -- "$backup" ;; \
            esac; \
        fi; \
    done
    sudo stow \
        --dir "{{ repo }}" \
        --target / \
        --restow \
        --no-folding \
        boot-compatibility
    sudo sh -eu -c ' \
        set -f; \
        portable_cmdline=""; \
        for argument in $(cat /etc/kernel/cmdline); do \
            case "$argument" in \
                acpi_backlight=*) continue ;; \
                root=/dev/*|resume=/dev/*) \
                    printf "%s\\n" "refusing non-portable kernel argument: $argument" >&2; \
                    exit 1 ;; \
            esac; \
            portable_cmdline="${portable_cmdline:+$portable_cmdline }$argument"; \
        done; \
        case "$portable_cmdline" in \
            *root=UUID=*|*root=PARTUUID=*) ;; \
            *) printf "%s\\n" "portable kernel command line requires root=UUID or root=PARTUUID" >&2; exit 1 ;; \
        esac; \
        printf "%s\\n" "$portable_cmdline" > /etc/kernel/cmdline-portable \
    '
    sudo mkinitcpio -P
    sudo grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot \
        --bootloader-id=GRUB \
        --removable \
        --recheck
    sudo grub-mkconfig -o /boot/grub/grub.cfg

# 檢查 UEFI loader、UKI、cmdline、microcode 與 fallback modules，不修改既有開機產物
boot-compatibility-check:
    sudo sh -eu -c ' \
        test "$(findmnt --target /boot --noheadings --output FSTYPE)" = vfat; \
        test -f /boot/EFI/BOOT/BOOTX64.EFI; \
        test -f /boot/EFI/Linux/arch-linux.efi; \
        test -f /boot/EFI/Linux/arch-linux-fallback.efi; \
        test -f /boot/grub/grub.cfg; \
        test -x /etc/grub.d/15_uki; \
        sh -n /etc/grub.d/15_uki; \
        if [ -e /etc/grub.d/15_uki.pre-stow ]; then test ! -x /etc/grub.d/15_uki.pre-stow; fi; \
        test -f /etc/default/grub.d/50-boot-compatibility.cfg; \
        grep -Fx "GRUB_DEFAULT=saved" /etc/default/grub.d/50-boot-compatibility.cfg; \
        grep -Fx "GRUB_SAVEDEFAULT=true" /etc/default/grub.d/50-boot-compatibility.cfg; \
        test -z "$(find /etc/grub.d /etc/kernel /etc/mkinitcpio.d -xtype l -print)"; \
        ! grep -Fq "Arch Linux (UKI)" /boot/grub/grub.cfg; \
        test -s /etc/kernel/cmdline-portable; \
        ! grep -Eq "(^| )acpi_backlight=" /etc/kernel/cmdline-portable; \
        ! grep -Eq "(^| )(root|resume)=/dev/" /etc/kernel/cmdline /etc/kernel/cmdline-portable; \
        grep -Eq "(^| )root=(UUID|PARTUUID)=" /etc/kernel/cmdline-portable \
    '
    test "$(sudo rg -c '^[[:space:]]*set blsuki_save_default=true[[:space:]]*$' /boot/grub/grub.cfg)" -eq 1
    test "$(sudo rg -c '^[[:space:]]*uki[[:space:]]*$' /boot/grub/grub.cfg)" -eq 1
    generated_config="$(sudo mktemp)"; \
    trap 'sudo rm -f "$generated_config"' EXIT; \
    sudo grub-mkconfig -o "$generated_config"; \
    test "$(sudo rg -c '^[[:space:]]*set blsuki_save_default=true[[:space:]]*$' "$generated_config")" -eq 1; \
    test "$(sudo rg -c '^[[:space:]]*uki[[:space:]]*$' "$generated_config")" -eq 1
    for uki in /boot/EFI/Linux/arch-linux.efi /boot/EFI/Linux/arch-linux-fallback.efi; do \
        early_contents="$(sudo lsinitcpio --early "$uki")"; \
        for microcode in AuthenticAMD GenuineIntel; do \
            grep -Fq "$microcode" <<<"$early_contents"; \
        done; \
    done
    fallback_contents="$(sudo lsinitcpio /boot/EFI/Linux/arch-linux-fallback.efi)"; \
    for module in vmd nvme ahci uas usb_storage; do \
        module_path="$(modinfo -F filename "$module")"; \
        if [ "$module_path" != '(builtin)' ]; then \
            grep -Fq "${module_path##*/}" <<<"$fallback_contents"; \
        fi; \
    done
    default_cmdline="$(sudo objcopy --dump-section .cmdline=/dev/stdout /boot/EFI/Linux/arch-linux.efi | tr '\0' '\n')"; \
    fallback_cmdline="$(sudo objcopy --dump-section .cmdline=/dev/stdout /boot/EFI/Linux/arch-linux-fallback.efi | tr '\0' '\n')"; \
    default_osrelease="$(sudo objcopy --dump-section .osrel=/dev/stdout /boot/EFI/Linux/arch-linux.efi | tr '\0' '\n')"; \
    fallback_osrelease="$(sudo objcopy --dump-section .osrel=/dev/stdout /boot/EFI/Linux/arch-linux-fallback.efi | tr '\0' '\n')"; \
    grep -Eq '(^| )acpi_backlight=native( |$)' <<<"$default_cmdline"; \
    ! grep -Eq '(^| )acpi_backlight=native( |$)' <<<"$fallback_cmdline"; \
    grep -Fx 'PRETTY_NAME="Arch Linux"' <<<"$default_osrelease"; \
    grep -Fx 'PRETTY_NAME="Arch Linux (fallback)"' <<<"$fallback_osrelease"

# 安裝並套用使用者與系統 Bash 設定
bash: system-bash
    just stow bash

# 安裝 Git 並套用 Git 使用者設定
git:
    sudo pacman -S --needed git stow
    just stow git

# 安裝 Ghostty 並套用終端機設定
ghostty:
    sudo pacman -S --needed ghostty stow
    just stow ghostty

# 安裝 tmux 並套用 tmux 設定
tmux:
    sudo pacman -S --needed tmux stow
    just stow tmux

# 透過 `yay` 安裝 Herdr 並套用設定
herdr:
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed herdr-bin
    if [ -e "{{ home }}/.config/herdr/config.toml" ] && [ ! -L "{{ home }}/.config/herdr/config.toml" ]; then \
        if [ -e "{{ home }}/.config/herdr/config.toml.pre-stow" ]; then \
            printf '%s\n' '~/.config/herdr/config.toml.pre-stow 已存在，為避免覆蓋備份而停止' >&2; \
            exit 1; \
        fi; \
        mv -- "{{ home }}/.config/herdr/config.toml" "{{ home }}/.config/herdr/config.toml.pre-stow"; \
    fi
    mkdir -p "{{ home }}/.config/herdr"
    stow \
        --dir "{{ repo }}" \
        --target "{{ home }}" \
        --restow \
        --no-folding \
        herdr

# 安裝 Neovim 與格式化工具，並套用編輯器設定
nvim: formatters
    sudo pacman -S --needed \
        neovim \
        nodejs \
        npm \
        luarocks \
        stylua \
        shfmt \
        ruff \
        prettier \
        taplo-cli \
        ripgrep \
        fd \
        tree-sitter-cli \
        lazygit \
        wl-clipboard \
        stow
    just stow nvim

# Hyprland 外部元件

# 建立桌布資源的 Stow 符號連結
wallpapers:
    sudo pacman -S --needed stow
    just stow wallpapers

# 安裝 SwayNC 並套用通知中心設定
swaync:
    sudo pacman -S --needed \
        swaync \
        libnotify \
        stow
    just stow swaync

# 安裝 SwayOSD 並套用音量與亮度 OSD 設定
swayosd:
    sudo pacman -S --needed \
        swayosd \
        stow
    sudo usermod --append --groups video "$USER"
    just stow swayosd

# 套用並啟用 systemd-oomd 記憶體壓力保護
systemd-oomd:
    sudo stow \
        --dir "{{ repo }}" \
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

# 安裝 Waybar 並套用狀態列與相關元件設定
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

# 安裝 Cliphist 並套用剪貼簿歷史設定
cliphist:
    sudo pacman -S --needed \
        cliphist \
        wl-clipboard \
        fuzzel \
        stow
    just stow cliphist
    systemctl --user daemon-reload

# 透過 `yay` 安裝 Wlogout 並套用電源選單設定
wlogout:
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed wlogout
    sudo pacman -S --needed stow
    just stow wlogout

# 透過 `yay` 安裝 Spotify，並設定原生 Wayland 啟動
spotify:
    @command -v yay >/dev/null || { \
        printf '%s\n' "找不到 yay，請先安裝 yay" >&2; \
        exit 1; \
    }
    yay -S --needed spotify
    sudo pacman -S --needed stow
    stow \
        --dir "{{ repo }}" \
        --target "{{ home }}" \
        --restow \
        --no-folding \
        spotify

# 安裝並套用 Hyprland、桌面元件與相關整合設定
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

# 安裝 `greetd` 與 `greetd-tuigreet` 登入管理員套件
login-manager:
    sudo pacman -S --needed greetd greetd-tuigreet

# 安裝完整 Hyprland 桌面環境與登入管理員
desktop: login-manager hyprland
    @printf '%s\n' "桌面套件與設定已完成"

# 安裝並套用 Bash、Git、Neovim、系統 locale 與 Hyprland 核心設定
all: bash git nvim system-locale hyprland
    @printf '%s\n' "所有 dotfiles 已完成"
