
### PROMPT ###
RED=1
GREEN=2
YELLOW=3
BLUE=4
CYAN=6
if [ $(id -u) -eq 0 ];
then
	PS1='$(tput bold)$(tput setaf $GREEN)\j $(tput setaf $BLUE)\w $(tput setaf $RED)\$$(tput sgr0) '
else
	PS1='$(tput bold)$(tput setaf $GREEN)\j $(tput setaf $BLUE)\w $(tput setaf $YELLOW)\$$(tput sgr0) '
fi
PS2='> '
