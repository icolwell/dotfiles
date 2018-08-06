#/bin/bash
set -e

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
)

custom_installs() {
	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/ros_install.bash | bash

	curl -sSL https://raw.githubusercontent.com/icolwell/install_scripts/master/atom_install.bash | bash

	# git-lfs
	curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
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
