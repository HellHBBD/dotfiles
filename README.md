# dotfiles

Arch Linux 個人桌面與純伺服器設定，使用 GNU Stow 與 `just` 管理。僅支援已完成基本安裝、可連線網路且可使用 `sudo` 的 Arch Linux。

## 安裝基本工具

```bash
sudo pacman -S --needed git just stow base-devel
```

桌面環境需要 AUR 的 `yay`。先閱讀 [yay 安裝說明](https://github.com/Jguer/yay/blob/next/README.md#installation) 與 `PKGBUILD`，確認後以一般使用者執行：

```bash
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
```

## 安裝 Rustup 與 Cargo

Rustup 會安裝 Rust toolchain 與 Cargo。

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

## 安裝 Cargo 套件

```bash
cargo install       \
    cargo-binstall  \
    cargo-expand    \
    cargo-audit     \
    cargo-watch     \
    cargo-update
```

## 下載設定

```bash
git clone https://github.com/HellHBBD/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## 安裝桌面環境

```bash
cd ~/dotfiles
just all
just login-manager
```

`just all` 會安裝 Bash、Git、Neovim、locale 與 Hyprland。`just login-manager` 僅安裝 greetd 套件，不會寫入 greetd 設定或啟用服務。

## 安裝 Steam

先在 `/etc/pacman.conf` 取消註解：

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

此 target 適用於 Intel + NVIDIA 混合顯示卡，會安裝 Steam、XWayland、兩張顯示卡的 32-bit Vulkan driver 與 NTSync：

```bash
cd ~/dotfiles
just steam
```

首次啟動後，在 `Steam -> Settings -> Compatibility` 啟用 Steam Play，並以 `Proton Experimental` 為預設。個別遊戲的 Proton 版本與相容性可參考 [ProtonDB](https://www.protondb.com/)。

## 安裝純伺服器

```bash
cd ~/dotfiles
just server
```

`server` 安裝 Bash、Git、headless Neovim、tmux 與個人 scripts；不安裝 GUI、AUR、Herdr、OpenCode、locale 或桌面服務。

## 安裝 TPM

[Tmux Plugin Manager](https://github.com/tmux-plugins/tpm/blob/master/README.md#installation) 是選用項目：

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

## 選用功能

```bash
just herdr
just spotify
just steam
just systemd-oomd
just boot-compatibility
just opencode
just --list
```

`boot-compatibility` 僅適用於 x86_64 UEFI、GRUB 與 ESP 掛載在 `/boot` 的系統。

## 注意事項

- Desktop recipes 需要先安裝 `yay`。
- Stow 前請備份可能衝突的既有設定。
- `just all` 與 `just server` 會管理 `/etc/bash.bashrc`；既有檔案會備份為 `.pre-stow`。
- Steam 需要 `multilib` 與 `en_US.UTF-8`；`just system-locale` 會產生 `zh_TW.UTF-8` 和 `en_US.UTF-8`，但不會將系統預設語言改為英文。
- Git 設定強制 GPG signing；提交前需自行匯入對應的 private key。
- Neovim 首次啟動需要網路下載 plugins 與 Mason tools。
- 使用 Hyprland 前，請檢查螢幕、鍵盤與觸控板設定。
- `tmux-init.sh` 會建立預設 tmux sessions；缺少的專案目錄會略過。
