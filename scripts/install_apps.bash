#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#------------------------------------------------------------------------------#
# App lists

# The 'core' is a collection of lightweight apps, these are installed when
# time is too short for a full install
CORE_APPS=(
	clang
	clang-format
	ctags
	expect
	git
	git-lfs
	gparted
	htop
	jstest-gtk
	nmap
	screen
	ssh
	tmux
	tree
	traceroute
	vim
	xclip
)

MAIN_APPS=(
	atom
	android-tools-adb
	default-jdk
	default-jre
	docker-ce
	filezilla
	gpsprune
	inkscape
	josm
	lm-sensors
	mercurial
	octave
	openvpn
	opera-stable
	pavucontrol
	pinta
	python-pip
	syncthing
	texlive
	texlive-latex-extra
	texlive-science
	texstudio
	virtualbox
	vlc
	wireshark
)

# Apps not usually needed on 'work' machines
ENTERTAINMENT_APPS=(
	minecraft-installer
	nautilus-dropbox
	spotify-client
	steam
)

# This list is specifically for plugin packages for the Atom text editor
ATOM_PACKAGES=(
	atom-beautify
	autocomplete-clang
	busy-signal
	clang-format
	git-time-machine
	intentions
	linter
	linter-ui-default
	linter-clang
	linter-shellcheck
	linter-cpplint
	language-lua
	language-cmake
	markdown-pdf
	minimap
	remote-edit
)

#------------------------------------------------------------------------------#
# Main entry point of script

main()
{
	repository_additions
	clear
	case "$1" in
		-e)
			echo "Installing entertainment apps only ..."
			sudo apt-get -y install "${ENTERTAINMENT_APPS[@]}"
			;;
		-c)
			echo "Installing core apps only ..."
			sudo apt-get -y install "${CORE_APPS[@]}"
			;;
		-a)
			echo "Installing all apps ..."
			sudo apt-get -y install "${ENTERTAINMENT_APPS[@]}"
			# Fall through
			;;&
		*)
			echo "Installing core and main apps ..."
			default_install
			;;
	esac
}

repository_additions()
{
	sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"
	sudo add-apt-repository multiverse
	sudo add-apt-repository -y ppa:webupd8team/atom
	sudo add-apt-repository -y ppa:thomas-schiex/blender
	sudo add-apt-repository -y ppa:minecraft-installer-peeps/minecraft-installer
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	# Spotify
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
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

default_install()
{
	sudo apt-get -y install "${CORE_APPS[@]}"
	sudo apt-get -y install "${MAIN_APPS[@]}"
	install_atom_packages "${ATOM_PACKAGES[@]}"

	# Other more complicated installations
	install_chrome
	install_ros
	install_go
}

#------------------------------------------------------------------------------#
# Custom Installs

install_chrome()
{
	if not_installed 'google-chrome-stable'; then
		TEMP_DIR=$(mktemp -d)
		cd "$TEMP_DIR"
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
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

install_ros()
{
	UBUNTU_CODENAME=$(lsb_release -s -c)
	case $UBUNTU_CODENAME in
		trusty)
			ROS_DISTRO=indigo;;
		xenial)
			ROS_DISTRO=kinetic;;
		*)
			echo "Unsupported version of Ubuntu detected. Only trusty (14.04.*) and xenial (16.04.*) are currently supported."
		exit 1
	esac

	sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu $UBUNTU_CODENAME main\" > /etc/apt/sources.list.d/ros-latest.list"
	wget -qO - http://packages.ros.org/ros.key | sudo apt-key add -

	echo "Updating package lists ..."
	sudo apt-get -qq update

	echo "Installing ROS $ROS_DISTRO ..."
	sudo apt-get -qq install ros-$ROS_DISTRO-desktop python-rosinstall > /dev/null

	source /opt/ros/$ROS_DISTRO/setup.bash

	# Prepare rosdep to install dependencies.
	echo "Updating rosdep ..."
	if [ ! -d /etc/ros/rosdep ]; then
		sudo rosdep init > /dev/null
	fi
	rosdep update > /dev/null
}

#------------------------------------------------------------------------------#
# Utility functions

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
