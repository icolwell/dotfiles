#/bin/bash
set -e

custom_installs() {
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/syncthing_install.bash | bash
}

custom_installs
