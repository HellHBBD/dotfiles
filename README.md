# dotfiles

這是一套供 Arch Linux 個人桌面使用的設定檔，透過 GNU Stow 將各元件連結到目前使用者的家目錄，並以 `just` 安裝對應套件與執行 Stow。本文件假設你已完成可開機的 Arch Linux 基本安裝、可使用網路，且有一個可執行 `sudo` 的一般使用者；不支援其他發行版。

> [!WARNING]
> 這些設定含有個人偏好，並非所有螢幕、GPU、鍵盤或觸控板都適用。首次進入圖形桌面前，請先閱讀並依本機硬體調整下列檔案：
>
> - `hyprland/.config/hypr/custom/monitors.lua`（目前筆電的輸出名稱、縮放與螢幕模式）
> - `hyprland/.config/hypr/hyprland/input.lua`（鍵盤配置、觸控板與手勢）
> - `hyprland/.config/hypr/hyprland/env.lua`（工作階段環境變數；GPU 專用設定應在確認相依項後再加入）
>
> 尤其不要直接假設 `eDP-1`、解析度或 GPU 設定適用於你的機器。`custom/monitors.lua` 建議先使用 `preferred`，登入後以 `hyprctl monitors all` 確認實際模式。

## 安裝前準備

在執行任何 recipe 前，先取得 Git、`just`、GNU Stow 與編譯 AUR 套件需要的 `base-devel`：

```sh
sudo pacman -S --needed git just stow base-devel
```

`hyprland` 會遞迴執行 `waybar` 與 `wlogout`，兩者都需要 `yay` 來安裝 AUR 套件。因此，在執行 `just desktop` 或 `just all` 前，必須先準備 `yay`。`yay` 位於 AUR，並非 Arch 官方倉庫套件：請先從 [AUR 的 yay 頁面](https://aur.archlinux.org/packages/yay) 檢閱 `PKGBUILD` 與來源；確認你接受其內容後，以一般使用者（不要用 root）建立套件。以下是可檢閱後執行的流程：

```sh
mkdir -p ~/build
git clone https://aur.archlinux.org/yay.git ~/build/yay
cd ~/build/yay
less PKGBUILD
makepkg -si
command -v yay
```

`makepkg -si` 僅會在安裝已建置的套件時要求權限。若不願使用 AUR helper，請不要執行 `desktop`、`all` 或 `hyprland`，因為目前的 `Justfile` 沒有無 `yay` 的替代路徑。

下列指令示範使用 SSH remote；請確認 GitHub SSH 金鑰已可用。將儲存庫放在 `~/dotfiles`：

```sh
git clone git@github.com:HellHBBD/dotfiles.git ~/dotfiles
cd ~/dotfiles
just --list
```

儲存庫根目錄的第一層目錄（例如 `bash/`、`nvim/`、`hyprland/`）是 Stow 套件。`just stow <套件>` 實際以儲存庫為 `--dir`、以 `$HOME` 為 `--target`，並使用 `--restow` 建立或更新連結；`just unstow <套件>` 則移除該套件的連結。開始前請先備份家目錄中會被連結覆蓋或衝突的既有設定。需要系統目錄的 package 會使用獨立的 Just target，並以 `/` 為 Stow target。

## Just targets

以下 targets 與根目錄 `Justfile` 相符；多數會以 `sudo pacman` 安裝套件，因此請先檢閱 recipe 與套件清單再執行。

| Target | 用途 |
| --- | --- |
| `stow <package>` / `unstow <package>` | 為指定 Stow 套件建立/更新連結，或移除連結。 |
| `formatters` | Stow `formatters` 設定。 |
| `bash` | 安裝並 Stow 使用者 Bash 設定，以及系統層級的 `system-bash` 設定。 |
| `system-bash` | 將 `/etc/bash.bashrc` 備份後，以 root-target Stow 管理系統 Bash 設定。 |
| `git`、`ghostty`、`tmux`、`nvim` | 安裝各自所需套件並 Stow 對應的基礎設定；`nvim` 會先執行 `formatters`。 |
| `herdr` | 透過 `yay` 安裝 `herdr-bin`，備份既有實體 `~/.config/herdr/config.toml` 後以 `--no-folding` Stow 設定；不納管 Herdr 的 session、log、socket 或 plugin lock。 |
| `wallpapers`、`swaync`、`swayosd`、`waybar`、`cliphist`、`wlogout` | 安裝並 Stow Hyprland 外部元件；`swayosd` 會將目前使用者加入 `video` 群組以控制背光，完成後須重新登入；`waybar` 依賴 `swaync`，`waybar` 與 `wlogout` 都要求系統已可使用 `yay`。 |
| `systemd-oomd` | 將 `systemd-oomd` 的 OOMD 與使用者 session drop-in Stow 至 `/etc`、啟用服務，並套用 memory-pressure 與 swap kill 保護。 |
| `spotify` | 透過 `yay` 安裝 Spotify，並 Stow Wayland 啟動器與 desktop entry；不會由其他 target 自動執行。 |
| `hyprland` | 先執行 `ghostty`、`tmux`、`wallpapers`、`swaync`、`swayosd`、`waybar`、`cliphist`、`wlogout`，再安裝 Hyprland/UWSM 與桌面相依套件、啟用 NetworkManager 與 Bluetooth，最後 Stow `hyprland`。 |
| `login-manager` | **只**安裝 `greetd` 與 `greetd-tuigreet` 套件；不會 Stow、複製設定檔，也不會啟用任何服務。 |
| `desktop` | 執行 `login-manager` 與 `hyprland`，適合準備桌面與登入管理員套件。 |
| `all` | 執行 `bash`、`git`、`nvim` 與 `hyprland`；它**不會**執行 `login-manager`。 |

例如，只安裝桌面套件與設定可執行：

```sh
just desktop
```

`desktop` 不包含 `bash`、`git` 或 `nvim`；反之，`all` 包含這三者與 `hyprland`，但不安裝登入管理員。若要使用 greetd，完成 `just desktop` 或另行執行 `just login-manager` 後，仍須依下一節手動安裝其設定並啟用服務。

## Herdr

`just herdr` 是選用 target，不會由 `desktop`、`hyprland` 或 `all` 遞迴執行。它需要已安裝且可使用的 `yay`，並安裝 AUR 套件 `herdr-bin`。若 `~/.config/herdr/config.toml` 是實體檔，recipe 會先移至 `~/.config/herdr/config.toml.pre-stow`；該備份已存在時會停止而不覆蓋。設定檔以 `--no-folding` Stow，因此 Herdr 自動建立的 `session.json`、log、socket 與 `.plugins.lock` 會保留在本機設定目錄，不會寫入 repository。

設定將 Herdr prefix 設為 `Ctrl-Space`，`Prefix` + `f` 開啟 workspace picker，`Prefix` + `Alt-g` 以 80% × 80% popup 開啟 `lazygit`。其他 Herdr 預設操作保留，例如 `Prefix` + `c` 建立 tab、`Prefix` + `h/j/k/l` 聚焦 pane、`Prefix` + `v` 或 `-` 分割 pane、`Prefix` + `z` zoom，以及 `Prefix` + `Shift-r` 重載設定。可用以下指令驗證設定：

```sh
herdr config check
```

## system-bash

`just system-bash` 會將現有的實體 `/etc/bash.bashrc` 移至 `/etc/bash.bashrc.pre-stow`，再將 `system-bash/etc/bash.bashrc` Stow 至 `/etc/bash.bashrc`。若備份檔已存在，recipe 會停止而不覆蓋它。`just bash` 會同時執行此 target 與使用者層級的 `bash` package。

系統設定檔會指向使用者可寫入的 repository，因此只適用於受信任的個人管理員帳號。驗證及還原方式如下：

```sh
readlink -f /etc/bash.bashrc

sudo stow --dir ~/dotfiles --target / --delete --no-folding system-bash
sudo mv -- /etc/bash.bashrc.pre-stow /etc/bash.bashrc
```

## systemd-oomd

`just systemd-oomd` 會將 `systemd-oomd/etc/systemd/system/user@.service.d/60-oomd-memory-pressure.conf` 與 `systemd-oomd/etc/systemd/oomd.conf.d/60-swap-used-limit.conf` Stow 至 `/etc`，啟用 `systemd-oomd`，並對目前使用者 session 設定 `ManagedOOMMemoryPressure=kill` 與 `ManagedOOMSwap=kill`。memory pressure 規則維持在 PSI 40%、持續 20 秒；40% 是 cgroup 中所有工作都遭延遲的時間比例，不是 RAM 使用率。

`SwapUsedLimit=70%` 僅在系統 RAM 使用率與系統 swap 使用率都超過 70% 時觸發；OOMD 會從啟用 `ManagedOOMSwap=kill` 的 cgroup descendant 中，選擇使用超過總 swap 5% 且 swap 使用量最高的候選者，以 `SIGKILL` 終止。未儲存的工作可能遺失。

系統 drop-in 會指向此 repository 內的檔案，因此可修改使用者可寫入的 dotfiles 來改變有效的 `/etc` 設定。這只適合受信任的個人管理員帳號；修改後需執行 `sudo systemctl daemon-reload` 與 `sudo systemctl restart systemd-oomd.service`。驗證可使用：

```sh
systemctl status systemd-oomd.service --no-pager
systemd-analyze cat-config systemd/oomd.conf
sudo systemctl show "user@$(id -u).service" \
  -p ManagedOOMSwap \
  -p ManagedOOMMemoryPressure \
  -p ManagedOOMMemoryPressureLimit \
  -p ManagedOOMMemoryPressureDurationUSec
oomctl dump
```

`oomctl dump` 應同時在 `Swap Monitored CGroups` 與 `Memory Pressure Monitored CGroups` 列出目前的 `user@UID.service`。

移除設定時執行：

```sh
sudo stow --dir ~/dotfiles --target / --delete --no-folding systemd-oomd
sudo systemctl daemon-reload
sudo systemctl set-property --runtime "user@$(id -u).service" \
  ManagedOOMSwap=auto \
  ManagedOOMMemoryPressure=auto \
  ManagedOOMMemoryPressureLimit= \
  ManagedOOMMemoryPressureDurationSec=
sudo systemctl restart systemd-oomd.service
```

## 設定 greetd

儲存庫的 greetd 範本是 `greetd/etc/greetd/config.toml`，內容會在 VT 1 啟動 `tuigreet --cmd 'uwsm start hyprland.desktop'`。請在確認 Hyprland 設定後，手動備份並安裝它：

```sh
(
  set -e
  sudo install -d -o root -g root -m 755 /etc/greetd
  backup="/etc/greetd/config.toml.bak.$(date +%Y%m%d-%H%M%S)"
  if [ -e /etc/greetd/config.toml ]; then
    sudo cp -a -- /etc/greetd/config.toml "$backup"
    printf '備份檔：%s\n' "$backup"
  fi
  sudo install -o root -g root -m 644 \
    greetd/etc/greetd/config.toml /etc/greetd/config.toml
)
```

若 `/etc/greetd/config.toml` 尚不存在，條件式不會建立備份。這個區塊在 subshell 中使用 `set -e`：建立目錄、備份或安裝任一步驟失敗時，後續步驟不會繼續執行，且不會改變互動式 shell 的錯誤處理設定。安裝後，`/etc/greetd/config.toml` 的擁有者應為 `root:root`、權限應為 `0644`。

啟用 greetd 前，先檢查是否已有其他顯示管理員：

```sh
systemctl status display-manager.service
systemctl is-enabled display-manager.service
systemctl list-units --type=service --state=running
systemctl list-unit-files --type=service --state=enabled
```

`status` 只顯示目前狀態；`is-enabled` 與 enabled unit 清單也能找出尚未啟動、但下次開機仍可能啟動的顯示管理員。逐一確認輸出中的顯示管理員 unit（例如 `sddm.service`、`gdm.service` 或 `lightdm.service`）確實是衝突來源後，才以其實際名稱停止並停用，例如：

```sh
sudo systemctl disable --now sddm.service
```

上例只適用於已確認正在使用 SDDM 的系統；GDM、LightDM 或其他服務須改用其對應 unit，絕對不要停用未辨識的 service。這些檢查、停止與停用動作**不會**由任何 Just target 自動執行。確認沒有衝突後，再手動啟用 greetd：

```sh
sudo systemctl enable greetd.service
```

## 首次登入、驗證與復原

重開機後，greetd 會顯示 `tuigreet`；以一般使用者登入時，範本會透過 UWSM 執行 `uwsm start hyprland.desktop` 來啟動 Hyprland。首次成功登入後，至少驗證螢幕與工作階段：

```sh
hyprctl monitors all
hyprctl clients
```

在確認螢幕、鍵盤、觸控板與網路皆可用，並確認上述機器專用設定沒有問題之前，請勿急著登出或重開機。請保留可用的 TTY：通常可按 `Ctrl`+`Alt`+`F2`（或其他未使用的 F-key VT）切換至文字主控台登入；greetd 範本使用的是 VT 1。

若 greetd 或圖形登入失敗，從 TTY 登入後可先檢查日誌：

```sh
systemctl status greetd.service
journalctl -b -u greetd.service
```

要回復最新的時間戳記備份，先確認找到的檔案後再執行：

```sh
(
  set -e
  backup="$(printf '%s\n' /etc/greetd/config.toml.bak.* | sort -r | head -n 1)"
  if [ ! -f "$backup" ]; then
    printf '%s\n' '找不到 greetd 設定備份；請勿覆寫目前設定。' >&2
    exit 1
  fi
  printf '將還原：%s\n' "$backup"
  sudo cp -a -- "$backup" /etc/greetd/config.toml
  sudo chown root:root /etc/greetd/config.toml
  sudo chmod 644 /etc/greetd/config.toml
  sudo systemctl restart greetd.service
)
```

同樣地，還原區塊中的 `set -e` 會在複製備份失敗時停止，因此不會接著變更擁有者、權限或重新啟動 greetd。

若沒有可用備份或需先回到純文字環境，可在 TTY 停用 greetd：

```sh
sudo systemctl disable --now greetd.service
```

之後修正 `/etc/greetd/config.toml` 或 Hyprland 的本機設定，再重新啟用 greetd。若先前使用其他顯示管理員，只有在確認其設定仍可用後才手動重新啟用它。
