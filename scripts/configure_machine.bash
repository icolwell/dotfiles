#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.bash"

# Paths to config locations
PUBLIC_CONFIGS_DIR="$REPO_DIR/configs"
PRIVATE_CONFIGS_DIR="$HOME/sync/dotfiles/common_configs"
SYSTEM_CONFIGS_DIR="$HOME/sync/dotfiles/sys_specific_configs/$HOSTNAME"

# Config locations
CONFIG_DIRS=(
	"$REPO_DIR/configs"
	"$HOME/sync/dotfiles/configs"
)


main()
{
	sudo -v
	if [ "$1" == '-c' ]; then
		echo "Applying common configs only ..."
	else
		for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
			get_classes "$CONFIG_DIR"
		done

		confirm_classes
	fi

	remove_stuff
	link_stuff
	setup_vim
	# configure_thunderbird
	# configure_gsettings
	# configure_systemd

	echo ""
	echo "Configuration complete!"
}

remove_stuff()
{
	# Remove unused folders
	rm -rf ~/Music
	rm -rf ~/Videos
	rm -rf ~/Templates
	rm -rf ~/Examples
}

link_stuff()
{
	for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
		process_config_container "$CONFIG_DIR"
	done
	# process_config_dir "$PUBLIC_CONFIGS_DIR"
	# process_config_dir "$PRIVATE_CONFIGS_DIR"
	# process_config_dir "$SYSTEM_CONFIGS_DIR"

	echo "Symlinks created successfully."
	echo ""
}

setup_vim()
{
	BUNDLE="$HOME/.vim/bundle"
	if [ ! -d "$BUNDLE/Vundle.vim" ]; then
		mkdir -p "$BUNDLE"
		git clone https://github.com/VundleVim/Vundle.vim.git "$BUNDLE/Vundle.vim"
	fi

	# Update existing (or new) installation
	cd "$BUNDLE/Vundle.vim"
	git pull -q
	vim -c VundleInstall -c quitall
	bash "$BUNDLE/fzf/install" --all >> /dev/null

	echo "Vim setup updated."
}

configure_thunderbird()
{
	# Thunderbird
	TB_PROFILE='Ian'
	TB_PROFILE_DIR="$HOME/.thunderbird/$TB_PROFILE"
	if [ -d $TB_PROFILE_DIR ] && hash thunderbird 2>/dev/null ; then
		# Remove any existing links or files
		rm -f ~/.thunderbird/Ian/ImapMail/imap-mail.outlook.com/msgFilterRules.dat
		rm -f ~/.thunderbird/Ian/ImapMail/imap.gmail.com/msgFilterRules.dat
		rm -f ~/.thunderbird/Ian/ImapMail/connect.uwaterloo.ca/msgFilterRules.dat

		ln -sf "$HOME/sync/dotfiles/thunderbird/imap-mail.outlook.com/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/imap-mail.outlook.com/msgFilterRules.dat
		ln -sf "$HOME/sync/dotfiles/thunderbird/imap.gmail.com/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/imap.gmail.com/msgFilterRules.dat
		ln -sf "$HOME/sync/dotfiles/thunderbird/connect.uwaterloo.ca/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/connect.uwaterloo.ca/msgFilterRules.dat
	else
		echo "Warning: no thunderbird profile named $TB_PROFILE exists, skipping thunderbird configuration"
	fi
}

configure_gsettings()
{
	gsettings set com.canonical.Unity.Launcher favorites \
		"['application://unity-control-center.desktop',
		'application://gnome-system-monitor.desktop',
		'application://org.gnome.Nautilus.desktop',
		'application://opera.desktop',
		'application://atom.desktop',
		'unity://expo-icon',
		'unity://devices',
		'unity://running-apps']"

	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
	gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ icon-size 42

	# Disable sticky edges
	dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-capture-mouse false

	# Default apps
	xdg-settings set default-web-browser opera.desktop
}

configure_systemd()
{
	echo "Enabling systemd services ..."
	# Systemd does not allow symlinks which is quite frustrating
	# We must place actual service files, not symlinks
	mkdir -p ~/.config/systemd/user
	wget -qP ~/.config/systemd/user/ https://raw.githubusercontent.com/syncthing/syncthing/master/etc/linux-systemd/user/syncthing.service
	systemctl --user enable syncthing.service
	systemctl --user start syncthing.service

	echo "systemd services enabled."
}

#------------------------------------------------------------------------------#
# Anything below this line should not require editing based on user preference

process_config_container()
{
	# This function takes in a config container directory and processes any
	# config categories in the container
	# $1 = Full path to config container directory

	# Always link common configs
	process_config_category "$1/common_configs"

	# Config based on class
	for CLASS in "${CLASSES[@]}"; do
		process_config_category "$1/class_configs/$CLASS"
	done

	# System-specific config
	process_config_category	"$1/sys_specific_configs/$HOSTNAME"
}

process_config_category()
{
	if [ -d "$1/home" ]; then
		setup_configs "$1/home" "$HOME"
	fi
	if [ -d "$1/root" ]; then
		setup_configs "$1/root" ""
	fi
}

setup_configs()
{
	# Loop over config folder and link config files
	# $1 = Full path to directory containing config files
	# $2 = Full path to destination root dir
	if [ ! -d "$1" ]; then
		echo "Warning: The following config directory was not found, skipping this directory."
		echo "	$1"
		return 0
	fi
	echo "Linking configs found in $1 to $2"

	configs=()

	cd "$1"
	while IFS=  read -r -d $'\0'; do
		# Remove the leading .
		string=${REPLY#*.}
		configs+=("$string")
	done < <(find . -type f -print0)

	for config in "${configs[@]}"; do
		link_config "$config" "$1" "$2"
	done
}

link_config()
{
	# $1 = Relative path to file from config root dir
	# $2 = Full path to config root dir
	# $3 = Full path to destination root dir
	LINK="$3$1"

	# Add sudo command if the folder is owned by root
	CONTAINING_DIR=$(dirname "$LINK")
	prefix=""
	if [ "$(stat -c '%U' "$CONTAINING_DIR")" == "root" ]; then
		prefix="sudo"
	fi

	backup_config "$prefix" "$LINK"

	$prefix mkdir -p "$CONTAINING_DIR"
	$prefix rm -f "$LINK"
	$prefix ln -sf "$2$1" "$LINK"
}

backup_config()
{
	# $1 = command prefix (sudo)
	# $2 = location of the file to backup

	FILE="$2"
	if [ ! -L "$FILE" ]; then
		# File is not a symlink, backup
		echo "Backing up file: $FILE"
		$1 cp "$FILE" "$FILE.backup"
	fi
}

main "$@"
