#!/bin/bash
set -e

# This script is to be run directly after a fresh install of the OS

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Update anything on the fresh install
sudo apt-get -y upgrade

# 1. Install all apps
bash "$SCRIPT_DIR/install_apps.bash"

# 2. Configure and customize the system
bash "$SCRIPT_DIR/configure_desktop.bash"
