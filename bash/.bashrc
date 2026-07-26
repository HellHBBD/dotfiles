# Only run in interactive shells
[[ $- != *i* ]] && return

### ALIASES ###
alias ls='eza --color=always'
alias la='eza -a'
alias ll='eza -alh'
alias l='eza'

alias cd..='cd ..'
alias grep='grep --color=always'

alias reload='source ~/.bashrc'
alias weather='curl wttr.in?lang=zh-tw'
alias clsmem='sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"'

alias pacman='sudo pacman --color always'
alias yay='yay --color always --sudoloop'

function update() {
    if [[ $# -eq 0 ]]; then
        # echo "正在更新系統..."
        yay -Syu --sudoloop --noconfirm
    else
        # echo "正在安裝軟件包: $*"
        yay -S "$@" --sudoloop --noconfirm
    fi
}

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
alias showBat='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias ip6="ip a | grep -Eo '(2[0-9a-fA-F]{0,3}:)([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}'"

nvims() {
    local -a items=("LazyVim" "default")
    local config

    config=$(
        printf '%s\n' "${items[@]}" |
            fzf \
                --prompt=" Neovim Config" \
                --height='~50%' \
                --layout=reverse \
                --border \
                --exit-0
    )

    if [[ -z $config ]]; then
        echo "Nothing selected"
        return 0
    fi

    [[ $config == default ]] && config=""

    NVIM_APPNAME="$config" nvim "$@"
}

### HISTORY ###
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=5000
export HISTFILESIZE=10000
shopt -s histappend
__sync_history() {
    builtin history -a
    builtin history -n
}

if [[ ";${PROMPT_COMMAND-};" != *";__sync_history;"* ]]; then
    PROMPT_COMMAND="__sync_history${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

### FZF ###
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"

    if declare -F __fzf_history__ &>/dev/null; then
        bind -m emacs-standard -x '"\e[A": __fzf_history__'
        bind -m vi-insert -x '"\e[A": __fzf_history__'
    fi
fi
# function search_history() {
#     local selection cmd
#     selection=$(history | awk '{$1=""; print substr($0,2)}' | tac | fzf --prompt="󰆔 Command History > " --border --exit-0 --expect=tab,enter)
#
#     # Parse the input, The first line is the key value (tab or enter), The second line is the selected command.
#     local key=$(echo "$selection" | head -n1)
#     cmd=$(echo "$selection" | tail -n1)
#
#     if [[ -n $cmd ]]; then
#         if [[ $key == "tab" ]]; then
#             # Tab -> paste command
#             READLINE_LINE="$cmd"
#             READLINE_POINT=${#READLINE_LINE}
#         else
#             # Enter -> execute command
#             eval "echo -e '$(tput setaf 3)▶ $(tput setaf 6)$cmd$(tput sgr0)'; $cmd"
#         fi
#     fi
# }

cddir() {
    if [[ $# -ne 1 ]]; then
        printf 'Usage: cddir DIRECTORY\n' >&2
        return 2
    fi

    mkdir -p -- "$1" && cd -- "$1"
}

### PATH ###
path_prepend() {
    case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
    esac
}
path_append() {
    case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
    esac
}
path_prepend "$HOME/shs"
path_prepend "/opt/cuda/bin"

export PATH

export BROWSER=zen-browser
