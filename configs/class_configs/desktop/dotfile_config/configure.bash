#!/bin/bash
set -e

remove_stuff()
{
	# Remove unused folders
	rm -rf ~/Music
	rm -rf ~/Videos
	rm -rf ~/Templates
	rm -rf ~/Examples
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

configure_thunderbird()
{
	MAIL_ACCOUNTS=(
		imap-mail.outlook.com
		imap.gmail.com
		connect.uwaterloo.ca
	)

	TB_PROFILE='Ian'
	TB_PROFILE_DIR="$HOME/.thunderbird/$TB_PROFILE"
	if [ -d $TB_PROFILE_DIR ] && hash thunderbird 2>/dev/null ; then
		for MAIL_ACCOUNT in "${MAIL_ACCOUNTS[@]}"; do
			MAIL_DIR="$HOME/.thunderbird/Ian/ImapMail/$MAIL_ACCOUNT"
			if [ -d "$MAIL_DIR" ]; then
				rm -f "$MAIL_DIR/msgFilterRules.dat"
				ln -sf "$HOME/sync/dotfiles/thunderbird/$MAIL_ACCOUNT/msgFilterRules.dat" "$MAIL_DIR/msgFilterRules.dat"
			else
				echo "No mail folder called $MAIL_ACCOUNT found, skipping"
			fi
		done
	else
		echo "Warning: no thunderbird profile named $TB_PROFILE exists, skipping thunderbird configuration"
	fi
}

configure_systemd()
{
	echo "Enabling systemd services ..."
	# Systemd does not allow symlinks which is quite frustrating
	# We must place actual service files, not symlinks
	mkdir -p ~/.config/systemd/user
	wget -qO ~/.config/systemd/user/syncthing.service https://raw.githubusercontent.com/syncthing/syncthing/master/etc/linux-systemd/user/syncthing.service
	systemctl --user enable syncthing.service
	systemctl --user start syncthing.service

	echo "systemd services enabled."
}

remove_stuff
configure_thunderbird
configure_gsettings
configure_systemd
