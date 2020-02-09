#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.bash"

main()
{
	# Hack for 'sudo -v' in docker containers
	sudo echo -n
	if [ "$1" == '-c' ]; then
		echo "Applying common configs only ..."
	else
		for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
			get_classes "$CONFIG_DIR"
		done

		confirm_classes
	fi

	link_stuff
	setup_vim

	echo "Running custom configuration scripts ..."
	for CUSTOM_CONFIG in "${CUSTOM_CONFIGS[@]}"; do
		bash "$CUSTOM_CONFIG"
	done

	echo ""
	echo "Configuration complete!"
}

link_stuff()
{
	for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
		process_config_container "$CONFIG_DIR"
	done

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
	CUSTOM_CONFIGURE_FILE="$1/dotfile_config/configure.bash"

	if [ -d "$1/home" ]; then
		setup_configs "$1/home" "$HOME"
	fi
	if [ -d "$1/root" ]; then
		setup_configs "$1/root" ""
	fi

	if [ -f "$CUSTOM_CONFIGURE_FILE" ]; then
		CUSTOM_CONFIGS+=("$CUSTOM_CONFIGURE_FILE")
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

	# Only create directories in the user's home. Missing directories in root
	# usually means the app is not installed.
	CONTAINING_DIR=$(dirname "$LINK")
	if [ ! -d "$CONTAINING_DIR" ] && [[ ! "$CONTAINING_DIR" == *"$HOME"* ]]; then
		echo "Skipping $LINK because containing folder does not exist"
		return
	fi

	mkdir -p "$CONTAINING_DIR"

	# Add sudo command if the folder is owned by root
    #dir_user="$(stat -c '%U' "$CONTAINING_DIR")"
    #file_user="$(stat -c '%U' "$LINK")"

	prefix=""
	if [ "$(stat -c '%U' "$CONTAINING_DIR")" != "$USER" ]; then
		prefix="sudo"
	fi

	backup_config "$prefix" "$LINK"
	$prefix rm -f "$LINK"
	$prefix ln -sf "$2$1" "$LINK"
}

backup_config()
{
	# $1 = command prefix (sudo)
	# $2 = location of the file to backup

	FILE="$2"
	if [ -f "$FILE" ] && [ ! -L "$FILE" ]; then
		# File is not a symlink, backup
		echo "Backing up file: $FILE"
		$1 cp "$FILE" "$FILE.backup"
		#sudo -u $1 "cp $FILE $FILE.backup"
	fi
}

main "$@"
