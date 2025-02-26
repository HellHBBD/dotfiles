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

# history setup
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=5000
export HISTFILESIZE=10000
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -n; history -r; $PROMPT_COMMAND"

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

bind -x '"\e[A": search_history'
function search_history() {
    local selection cmd
    selection=$(history | awk '{$1=""; print substr($0,2)}' | tac | fzf --prompt="󰆔 Command History > " --border --exit-0 --expect=tab,enter)

    # Parse the input, The first line is the key value (tab or enter), The second line is the selected command.
    local key=$(echo "$selection" | head -n1)
    cmd=$(echo "$selection" | tail -n1)

    if [[ -n $cmd ]]; then
        if [[ $key == "tab" ]]; then
            # Tab -> paste command
            READLINE_LINE="$cmd"
            READLINE_POINT=${#READLINE_LINE}
        else
            # Enter -> execute command
            eval "$cmd"
        fi
    fi
}

# zoxide setup (keep at bottom of .bashrc)
eval "$(zoxide init bash)"
