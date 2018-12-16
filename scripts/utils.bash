#!/bin/bash
set -e

source "$SCRIPT_DIR/settings.bash"

get_classes()
{
	# This function looks to see if any system-specific or class settings exist
	# $1 = Config container directory

	CLASS_FILE="$1/sys_specific_configs/$HOSTNAME/dotfile_config/class.txt"

	if [ -f "$CLASS_FILE" ]; then
		mapfile -t -O "${#CLASSES[@]}" CLASSES < "$CLASS_FILE"
	fi
}

confirm_classes()
{
	if [ -z "$CLASSES" ]; then
		echo "This machine (named $HOSTNAME) was not assigned any configuration class."
		echo "Only common apps and configurations will be installed."
		echo "Do you wish to continue? (y/n):"

		while read ans; do
			case "$ans" in
				y) break;;
				n) exit; break;;
				*) echo "(y/n):";;
			esac
		done
	else
		echo "The following classes were found for this machine (named $HOSTNAME):"
		printf '%s\n' "${CLASSES[@]}"
		echo ""
	fi
}
