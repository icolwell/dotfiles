# Scripts

**install_apps.bash [-c]**  
Automatically installs ubuntu packages defined in the
`dotfile_config/apt_packages.txt` files.
After apt installation, the `dotfile_config/install.bash` scripts are executed
if they exist.

Use the `-c` flag to install only common apps.

**configure_machine.bash [-c]**  
Symlinks configs found in all applicable config folders.
Runs any `dotfile_config/configure.bash` scripts if they exist.

Use the `-c` flag to only link common configs.

**initialize_system.bash**  
Simply calls the above two scripts. It is meant to be used right after
installing Ubuntu or to update the existing system if any dotfiles or apps
change.

## Process

Both `install_apps.bash` and `configure_machine.bash` start by loading all
applicable classes and applying changes from all config container locations.
configs are applied in the following order:
1. common_configs
2. class_configs
3. sys_specific_configs

So if the same config file exists in both common and class, the class-specific
one will be used.
