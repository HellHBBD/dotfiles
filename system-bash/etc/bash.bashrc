#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prevent double sourcing
if [[ -z "${BASHRCSOURCED}" ]]; then
    BASHRCSOURCED="Y"

    # Terminal title
    case ${TERM} in
    Eterm* | alacritty* | aterm* | foot* | ghostty* | gnome* | konsole* | kterm* | putty* | rxvt* | tmux* | xterm*)
        PROMPT_COMMAND+=(
            'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        )
        ;;
    screen*)
        PROMPT_COMMAND+=(
            'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        )
        ;;
    esac

    ### PROMPT ###

    RED=1
    GREEN=2
    YELLOW=3
    BLUE=4
    CYAN=6

    if [[ "$(id -u)" -eq 0 ]]; then
        PS1='$(tput bold)$(tput setaf "$GREEN")\j $(tput setaf "$BLUE")\w $(tput setaf "$RED")\$$(tput sgr0) '
    else
        PS1='$(tput bold)$(tput setaf "$GREEN")\j $(tput setaf "$BLUE")\w $(tput setaf "$YELLOW")\$$(tput sgr0) '
    fi

    PS2='> '
fi

# Bash completion
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
fi
