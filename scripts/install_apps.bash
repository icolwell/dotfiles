#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.bash"

# Config locations
CONFIG_DIRS=(
	"$REPO_DIR/configs"
	"$HOME/df_sync/configs"
)

main()
{
	if [ -z "CONTINUOUS_INTEGRATION" ]; then
		sudo -v
	fi
	
	if [ "$1" == '-c' ]; then
		echo "Installing common apps only ..."
	else
		for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
			get_classes "$CONFIG_DIR"
		done

		confirm_classes
	fi

	repository_additions
	clear

	# CUSTOM_INSTALLS=()
	for CONFIG_DIR in "${CONFIG_DIRS[@]}"; do
		echo "Loading configs from $CONFIG_DIR ..."
		# Always install common apps
		load_dotfile_configs "$CONFIG_DIR/common_configs"

		# Install apps based on class
		for CLASS in "${CLASSES[@]}"; do
			load_dotfile_configs "$CONFIG_DIR/class_configs/$CLASS"
		done

		# Install system-specific apps
		load_dotfile_configs "$CONFIG_DIR/sys_specific_configs/$HOSTNAME"
	done

	echo ""
	echo "Apps to be installed:"
	echo "${APPS[@]}"
	echo ""

	echo "Custom install scripts found:"
	echo "${CUSTOM_INSTALLS[@]}"
	echo ""

	echo "Installing ..."
	sudo apt-get -y install "${APPS[@]}"

	echo "Running custom install scripts ..."
	for CUSTOM_INSTALL in "${CUSTOM_INSTALLS[@]}"; do
		bash "$CUSTOM_INSTALL"
	done

	echo ""
	echo "Installation Complete!"
}

repository_additions()
{
	# This list of respositories gets added to all machines, but the apps are
	# only installed if they appear in the machine's list

	sudo apt-get -qq install curl wget software-properties-common
	#sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"
	#sudo add-apt-repository multiverse

	echo "Updating package lists ..."
	sudo apt-get update -qq
}

load_dotfile_configs()
{
	APT_PKG_FILE="$1/dotfile_config/apt_packages.txt"
	DEBCONF_FILE="$1/dotfile_config/debconf_selections.txt"
	CUSTOM_INSTALL_FILE="$1/dotfile_config/install.bash"

	if [ -f "$APT_PKG_FILE" ]; then
		mapfile -t -O "${#APPS[@]}" APPS < "$APT_PKG_FILE"
	fi

	if [ -f "$DEBCONF_FILE" ]; then
		sudo debconf-set-selections -v "$DEBCONF_FILE"
	fi

	if [ -f "$CUSTOM_INSTALL_FILE" ]; then
		CUSTOM_INSTALLS+=("$CUSTOM_INSTALL_FILE")
	fi
}

not_installed() {
	res=$(dpkg-query -W -f='${Status}' "$1" 2>&1)
	if [[ "$res" == "install ok installed"* ]]; then
		echo "$1 is already installed"
		return 1
	fi
	return 0
}

main "$@"
