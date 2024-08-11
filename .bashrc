### ALIASES ###
alias ls='eza --color=auto'
alias la='eza -a'
alias ll='eza -alh'
alias l='eza'

alias cd..='z ..'
alias cd='z'

alias cat='bat --color=auto'

alias grep='grep --color=auto'

alias reset='reset; source ~/.bashrc'
alias weather='curl wttr.in?lang=zh-tw'
alias clsmem='sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"'

alias pacman='sudo pacman --color auto'
alias yay='yay --color auto --sudoloop'
alias update='yay --color auto --noconfirm --sudoloop --needed'

alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias clean='yay -Scc'

# This will generate a list of explicitly installed packages
alias list="sudo pacman -Qqe"
# This will generate a list of explicitly installed packages without dependencies
alias listt="sudo pacman -Qqet"
# list of AUR packages
alias listaur="sudo pacman -Qqem"

### PERSONAL ###
alias cls='clear'
alias su='sudo -s'
alias logout='sudo pkill -SIGKILL -u '
alias showBat='upower -i /org/freedesktop/UPower/devices/battery_BAT0'

# ssh in kitty
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# open existing tmux or create new one
# alias tmux='tmux a &> /dev/null || tmux &> /dev/null'

# zoxide setup
eval "$(zoxide init bash)"

# atuin setup
export PROMPT_COMMAND="history -a; history -n"
export HISTSIZE=50
export HISTFILESIZE=50
# [[ $- == *i* ]] && source /usr/share/blesh/ble.sh
eval "$(atuin init bash)" &> /dev/null
# source .sync-history.sh
atuin import bash &> /dev/null
bind -x '"\C-r": __atuin_history'

# fzf setup
source <(fzf --bash)

# Append our default paths
export PATH=~/scripts/bin:$PATH

# source ~/.bashrc.d/systemd
. "$HOME/.cargo/env"

alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"

function nvims() {
    items=("LazyVim" "default")
    config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config" --height=~50% --layout=reverse --border --exit-0)
    if [[ -z $config ]]; then
        echo "Nothing selected"
        return 0
    elif [[ $config == "default" ]]; then
        config=""
    fi
    NVIM_APPNAME=$config nvim $@
}
