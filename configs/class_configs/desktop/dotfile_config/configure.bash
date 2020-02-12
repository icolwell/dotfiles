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
	# Launcher favorites
	gsettings set org.gnome.shell favorite-apps \
		"['gnome-control-center.desktop',
		'org.gnome.Nautilus.desktop',
		'org.gnome.Terminal.desktop',
		'opera.desktop',
		'atom.desktop',
		'thunderbird.desktop']"

	# List content in file browser
	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

	# Small icon size in file browser
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'

	# Icon size of dock apps
	gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36

	# AM/PM clock view
	gsettings set org.gnome.desktop.interface clock-format '12h'

	# Show date in clock view
	gsettings set org.gnome.desktop.interface clock-show-date 'true'

	# Default apps
	xdg-settings set default-web-browser opera.desktop
}

configure_thunderbird()
{
	MAIL_ACCOUNTS=(
		outlook.office365.com
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
				ln -sf "$HOME/df_sync/thunderbird/$MAIL_ACCOUNT/msgFilterRules.dat" "$MAIL_DIR/msgFilterRules.dat"
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
	if [ -z "$CI" ]; then
		systemctl --user start syncthing.service
	fi

	echo "systemd services enabled."
}

remove_stuff
configure_thunderbird
configure_gsettings
configure_systemd
