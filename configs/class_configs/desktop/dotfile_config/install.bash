#!/bin/bash
set -e

ATOM_PACKAGES=(
	atom-beautify
	auto-detect-indentation
	autocomplete-clang
	busy-signal
	clang-format
	git-time-machine
	intentions
	language-cmake
	language-lua
	linter
	linter-clang
	linter-cpplint
	linter-shellcheck
	linter-ui-default
	markdown-pdf
	minimap
	sort-lines
)

custom_installs() {
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/ros_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/opera_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/atom_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/syncthing_install.bash | bash
	# curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/slack_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/spotify_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/docker_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/signal_install.bash | bash
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/chrome_install.bash | bash
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

custom_installs

install_atom_packages "${ATOM_PACKAGES[@]}"
