#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export INPUT_METHOD=fcitx
export GLFW_IM_MODULE=ibus

### EXPORT ###
export EDITOR='nvim'
export VISUAL='nvim'
export HISTCONTROL=ignoreboth:erasedups
export PAGER='less'

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[ -f /home/hellhbbd/.dart-cli-completion/bash-config.bash ] && . /home/hellhbbd/.dart-cli-completion/bash-config.bash || true
## [/Completion]
