#!/bin/bash
set -e

#TODO: Move this to install_script repo
# RPI monitor install

sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2C0D3C0F
sudo wget http://goo.gl/vewCLL -O /etc/apt/sources.list.d/rpimonitor.list
sudo apt-get update
sudo apt-get -y install rpimonitor
sudo /etc/init.d/rpimonitor update
