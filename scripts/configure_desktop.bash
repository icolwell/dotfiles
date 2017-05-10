#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PUB_CONFIGS_DIR="$REPO_DIR/configs"
PRIV_CONFIGS_DIR="$HOME/Dropbox/dotfiles/configs"

main()
{
	check_apps
	remove_stuff
	link_stuff
	setup_vim
	configure_gsettings
}

check_apps()
{
	# Thunderbird
	TB_PROFILE='Ian'
	TB_PROFILE_DIR="$HOME/.thunderbird/$TB_PROFILE"
	AP_THUNDERBIRD=
	if [ -d $TB_PROFILE_DIR ] && hash thunderbird 2>/dev/null ; then
		AP_THUNDERBIRD=1
	else
		echo "Warning: no thunderbird profile named $TB_PROFILE exists, skipping thunderbird configuration"
	fi
}

remove_stuff()
{
	# Remove any existing links or files
	rm -f ~/.profile

	if [[ -n $AP_THUNDERBIRD ]]; then
		rm -f ~/.thunderbird/Ian/ImapMail/imap-mail.outlook.com/msgFilterRules.dat
		rm -f ~/.thunderbird/Ian/ImapMail/imap.gmail.com/msgFilterRules.dat
		rm -f ~/.thunderbird/Ian/ImapMail/connect.uwaterloo.ca/msgFilterRules.dat
	fi

	# Remove unused folders
	rm -rf ~/Music
	rm -rf ~/Videos
	rm -rf ~/Templates
	rm -rf ~/Pictures
	rm -rf ~/Examples
}

link_stuff()
{
	if [[ -n $AP_THUNDERBIRD ]]; then
		ln -sf "$HOME/Dropbox/dotfiles/thunderbird/imap-mail.outlook.com/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/imap-mail.outlook.com/msgFilterRules.dat
		ln -sf "$HOME/Dropbox/dotfiles/thunderbird/imap.gmail.com/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/imap.gmail.com/msgFilterRules.dat
		ln -sf "$HOME/Dropbox/dotfiles/thunderbird/connect.uwaterloo.ca/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/connect.uwaterloo.ca/msgFilterRules.dat
	fi

	setup_configs "$PUB_CONFIGS_DIR"
	setup_configs "$PRIV_CONFIGS_DIR"

	echo "Symlinks created successfully."
}

link_config()
{
	# $1 = Relative path to file from config root dir
	# $2 = Full path to config root dir
	LINK="$HOME$1"

	mkdir -p "$(dirname "$LINK")"
	rm -f "$LINK"
	ln -sf "$2$1" "$LINK"
}

setup_configs()
{
	# Loop over config folder and link config files
	# $1 = Full path to directory containing config files
	if [ ! -d "$1" ]; then
		echo "Warning: The following config directory was not found, skipping this directory."
		echo "$1"
		return 0
	fi

	configs=()

	cd "$1"
	while IFS=  read -r -d $'\0'; do
		# Remove the leading .
		string=${REPLY#*.}
		configs+=("$string")
	done < <(find . -type f -print0)

	for config in "${configs[@]}"; do
		link_config "$config" "$1"
	done
}

setup_vim()
{
	BUNDLE="$HOME/.vim/bundle"
	if [ ! -d "$BUNDLE/Vundle.vim" ]; then
		mkdir -p "$BUNDLE"
		git clone https://github.com/VundleVim/Vundle.vim.git "$BUNDLE/Vundle.vim"
	fi

	# Update existing (or new) installation
	cd "$BUNDLE/Vundle.vim"
	git pull -q
	vim -c VundleInstall -c quitall
	bash "$BUNDLE/fzf/install" --all >> /dev/null

	echo "Vim setup updated."
}

configure_gsettings()
{
	gsettings set com.canonical.Unity.Launcher favorites \
		"['application://unity-control-center.desktop',
		'application://gnome-system-monitor.desktop',
		'application://org.gnome.Nautilus.desktop',
		'application://opera.desktop',
		'application://atom.desktop',
		'unity://expo-icon',
		'unity://devices',
		'unity://running-apps']"

	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
	gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ icon-size 42

	# Disable sticky edges
	dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-capture-mouse false

	# Default apps
	xdg-settings set default-web-browser opera.desktop
}

main
