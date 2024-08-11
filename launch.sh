ROOT_PATH=$(pwd)
CONFIG_PATH=$HOME/.config

# use confirm function
confirm() {
	while true; do
		read -p "$1 [y/n]: " yn
		case $yn in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Invalid option!";;
		esac
	done
}

# create symbolic link
link() {
	name=$1
	src=$2/$1
	dest=$3/$1
	if confirm "Configure $name?"; then
		ln -s "$src" "$dest" && echo "Create symbolic link $src -> $dest"
	fi
}

link .bashrc $ROOT_PATH $HOME
link .bash_profile $ROOT_PATH $HOME
link i3 $ROOT_PATH $CONFIG_PATH
link kitty $ROOT_PATH $CONFIG_PATH
link nvim $ROOT_PATH $CONFIG_PATH
link polybar $ROOT_PATH $CONFIG_PATH
link rofi $ROOT_PATH $CONFIG_PATH
link tmux $ROOT_PATH $CONFIG_PATH

# if confirm "append text to /etc/bash.bashrc (need permission)"; then
# 	sudo cat bash.bashrc >> /etc/bash.bashrc
# fi
