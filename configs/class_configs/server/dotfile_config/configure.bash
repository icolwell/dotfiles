#!/bin/bash
set -e

configure_syncthing()
{
    # The service file can not be symlinked for some reason
    sudo wget -o /etc/systemd/system/syncthing@.service https://raw.githubusercontent.com/syncthing/syncthing/master/etc/linux-systemd/system/syncthing%40.service
    systemctl enable "syncthing@$USER.service"
    systemctl start "syncthing@$USER.service"
}

configure_syncthing
