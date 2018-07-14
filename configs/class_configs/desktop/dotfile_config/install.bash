#/bin/bash
set -e

curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/ros_install.bash | bash

# git-lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
