#/bin/bash
set -e

custom_installs() {
	# git-lfs
	curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
}

custom_installs
