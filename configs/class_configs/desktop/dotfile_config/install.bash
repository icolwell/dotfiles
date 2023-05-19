#!/bin/bash
set -e

custom_installs() {
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/ros_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/brave_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/syncthing_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/spotify_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/signal_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/chrome_install.bash | bash
}

custom_installs
