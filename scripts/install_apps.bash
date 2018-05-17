#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.bash"

# Config locations
CONFIG_DIRS=(
	"$REPO_DIR/configs"
	"$HOME/sync/dotfiles/configs"
)

main()
{
	sudo -v
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

	echo "Atom packages to be installed:"
	echo "${ATOM_PACKAGES[@]}"
	echo ""

	echo "Custom install scripts found:"
	echo "${CUSTOM_INSTALLS[@]}"
	echo ""

	echo "Installing ..."
	sudo apt-get -y install "${APPS[@]}"
	install_atom_packages "${ATOM_PACKAGES[@]}"

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

	sudo apt-get -qq install curl wget
	sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"
	sudo add-apt-repository multiverse
	sudo add-apt-repository -y ppa:webupd8team/atom
	sudo add-apt-repository -y ppa:minecraft-installer-peeps/minecraft-installer
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	# Spotify
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
	echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list

	# Opera
	wget -O - http://deb.opera.com/archive.key | sudo apt-key add -
	echo 'deb https://deb.opera.com/opera-stable/ stable non-free' | sudo tee /etc/apt/sources.list.d/opera-stable.list

	# Syncthing
	curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

	# git-lfs
	curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash

	# Docker
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	echo "Updating package lists ..."
	sudo apt-get update -qq
}

load_dotfile_configs()
{
	APT_PKG_FILE="$1/dotfile_config/apt_packages.txt"
	ATOM_PKG_FILE="$1/dotfile_config/atom_packages.txt"
	DEBCONF_FILE="$1/dotfile_config/debconf_selections.txt"
	CUSTOM_INSTALL_FILE="$1/dotfile_config/install.bash"

	if [ -f "$APT_PKG_FILE" ]; then
		mapfile -t -O "${#APPS[@]}" APPS < "$APT_PKG_FILE"
	fi

	if [ -f "$ATOM_PKG_FILE" ]; then
		mapfile -t -O "${#ATOM_PACKAGES[@]}" ATOM_PACKAGES < "$ATOM_PKG_FILE"
	fi

	if [ -f "$DEBCONF_FILE" ]; then
		sudo debconf-set-selections -v "$DEBCONF_FILE"
	fi

	if [ -f "$CUSTOM_INSTALL_FILE" ]; then
		CUSTOM_INSTALLS+=("$CUSTOM_INSTALL_FILE")
	fi
}

install_chrome()
{
	if not_installed 'google-chrome-stable'; then
		TEMP_DIR=$(mktemp -d)
		cd "$TEMP_DIR"
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo apt -y install ./google-chrome-stable_current_amd64.deb
	fi
}

install_go()
{
	VERSION="1.8.3"

	if [ -d /usr/local/go ]; then
		echo "GO is already installed"
	else
		TEMP_DIR=$(mktemp -d)
		cd "$TEMP_DIR"
		wget https://storage.googleapis.com/golang/go$VERSION.linux-amd64.tar.gz
		sudo tar -C /usr/local -xzf go$VERSION.linux-amd64.tar.gz
	fi
}

install_atom_packages()
{
	ARRAY=("$@")
	for atmpkg in "${ARRAY[@]}"; do
		if [[ ! -d "$HOME/.atom/packages/$atmpkg" ]]; then
			apm install "$atmpkg"
		else
			echo "atom package $atmpkg is already installed"
		fi
	done
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
