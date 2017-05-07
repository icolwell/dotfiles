#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

main()
{
	clear
	if [ "$1" = '-c' ]; then
		printf "Installing core apps only ...\n\n"
		install_core
		exit
	fi

	printf "Performing full installation ...\n\n"
	repository_additions
	install_core
	install_extras

	echo "Install finished successfully :D"
}

repository_additions()
{
	sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"
	sudo add-apt-repository multiverse
	sudo add-apt-repository -y ppa:webupd8team/atom
	sudo add-apt-repository -y ppa:thomas-schiex/blender

	# Spotify
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
	echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list

	# Opera
	wget -O - http://deb.opera.com/archive.key | sudo apt-key add -
	echo 'deb http://deb.opera.com/opera-stable/ stable non-free' | sudo tee /etc/apt/sources.list.d/opera.list

	echo "Updating package lists ..."
	sudo apt-get update -qq
}

install_core()
{
	# The 'core' is a collection of lightweight apps, these are installed when
	# time is too short for a full install

	# Array of apps to install in alphabetical order
	APPS=(
		clang
		clang-format
		ctags
		expect
		gparted
		jstest-gtk
		screen
		tmux
		tree
		traceroute
		vim
		htop
	)
	sudo apt-get -y install "${APPS[@]}"
}

install_extras()
{
	# Apps installed via apt-get
	APPS=(
		atom
		android-tools-adb
		default-jdk
		default-jre
		filezilla
		gpsprune
		inkscape
		josm
		nautilus-dropbox
		octave
		opera-stable
		pinta
		python-pip
		redshift
		redshift-gtk
		skype
		spotify-client
		steam
		texlive
		texlive-latex-extra
		texlive-science
		texstudio
		virtualbox
		vlc
	)
	sudo apt-get -y install "${APPS[@]}"

	# Atom packages
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
		minimap
		remote-edit
	)
	install_atom_packages "${ATOM_PACKAGES[@]}"

	# Other more complicated installations
	install_chrome
	install_ros
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

install_chrome()
{
	if not_installed 'google-chrome-stable'; then
		TEMP_DIR=$(mktemp -d)
		cd "$TEMP_DIR"
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
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

not_installed() {
	res=$(dpkg-query -W -f='${Status}' "$1" 2>&1)
	if [[ "$res" == "install ok installed"* ]]; then
		echo "$1 is already installed."
		return 1
	fi
	return 0
}

main "$@"
