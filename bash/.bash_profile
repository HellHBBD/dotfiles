#
# ~/.bash_profile
#

if command -v fcitx5 >/dev/null 2>&1; then
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    export SDL_IM_MODULE=fcitx
    export INPUT_METHOD=fcitx
    export GLFW_IM_MODULE=ibus
fi

### EXPORT ###
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

### COMPLETION ###
dart_completion="$HOME/.dart-cli-completion/bash-config.bash"
[[ -f $dart_completion ]] && . "$dart_completion"
unset dart_completion

### CARGO ###
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

### INTERACTIVE SHELL ###
[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
