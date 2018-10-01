#/bin/bash
set -e

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
	# Thunderbird
	TB_PROFILE='Ian'
	TB_PROFILE_DIR="$HOME/.thunderbird/$TB_PROFILE"
	if [ -d $TB_PROFILE_DIR ] && hash thunderbird 2>/dev/null ; then
		# Remove any existing links or files
		rm -f ~/.thunderbird/Ian/ImapMail/imap-mail.outlook.com/msgFilterRules.dat
		rm -f ~/.thunderbird/Ian/ImapMail/imap.gmail.com/msgFilterRules.dat
		rm -f ~/.thunderbird/Ian/ImapMail/connect.uwaterloo.ca/msgFilterRules.dat

		ln -sf "$HOME/sync/dotfiles/thunderbird/imap-mail.outlook.com/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/imap-mail.outlook.com/msgFilterRules.dat
		ln -sf "$HOME/sync/dotfiles/thunderbird/imap.gmail.com/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/imap.gmail.com/msgFilterRules.dat
		ln -sf "$HOME/sync/dotfiles/thunderbird/connect.uwaterloo.ca/msgFilterRules.dat" ~/.thunderbird/Ian/ImapMail/connect.uwaterloo.ca/msgFilterRules.dat
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

configure_thunderbird
configure_gsettings
configure_systemd
