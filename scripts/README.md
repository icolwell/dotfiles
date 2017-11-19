# Scripts

**configure_desktop.bash**  
Symlinks any configs found in the `configs` folder or any other private folders
you specify. Configuration of Thunderbird, unity and vim is also performed
(Credit for any Vim configs/setup in this repo goes to [chutsu](https://github.com/chutsu/dotfiles)).

**install_apps.bash**  
Automatically installs ubuntu packages and atom plugins as well as some more
complicated custom installs (ROS, chrome).

Use the `-c` flag to indicate only a core installation (core installation
performs a smaller install if time is limited).

Use the `-e` flag to install "entertainment" apps. Basically just a category of
apps that I don't want installed by default on work machines.

Use the `-a` flag to install apps from all categories.

**initialize_system.bash**  
Simply calls the above two scripts. It is meant to be used right after
installing Ubuntu or to update the existing system if any dotfiles or apps
change.
