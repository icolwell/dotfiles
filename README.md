# dotfiles [![CircleCI](https://circleci.com/gh/icolwell/dotfiles.svg?style=svg)](https://circleci.com/gh/icolwell/dotfiles)

This repo contains scripts to automatically install applications and configure
both the desktop and terminal environment. The two main goals of this repo are:
1. To be able to install a fresh copy of Ubuntu and then simply run a single
script to set everything up "the way it was before".
2. To backup configurations and sync them across multiple systems.

Additional Features
- Automatic installation of all your apps.
- Classification of configurations into groups such as "server", "desktop",
"personal", "work", etc.
- Easy support for host-specific configs.
- debconf preconfiguration to avoid user input prompts during installation.

NOTE: These dotfiles and scripts have only been tested on Ubuntu 18.04. It is
possible that they no longer work for 16.04 or other versions.

## Installation Instructions

If you wish start managing your own dotfiles immediately then I suggest the
following:

1. Fork your own copy of this repo. (optional)\*
2. Clone that fork to your PC using the following:  
```
git clone git@github.com:icolwell/dotfiles.git ~/dotfiles
```  
(Change the `icolwell` to your account if you forked your own)
3. Run the initialization script:  
```
bash ~/dotfiles/scripts/initialize_system.bash
```

All done! the apps are installed and configured according to the settings in
this repo. You may now wish to customize your configs to your own preferences,
see the following sections for short explanations on how things are arranged.

\* You can simply clone my repo without forking if you just want to get up and
running fast.

## Customizing this dotfiles repo to your own preferences

If you want to use this repo for your own dotfiles feel free to fork or copy.
You will most likely want to modify at least the following things, although it
is totally optional of course:

- `configs/common_configs/home` folder to contain your configs
(or just use mine)
- `configs/common_configs/dotfile_config` meta configs, keep reading for more
details.
- `scripts/settings.bash` path to any private config containers.

## Folder Structure

I designed the folder structure to be as configurable as possible.
There are three main config categories:
- `common_configs`: Config files that are to be installed on every machine.
If you only have one machine, you can just dump all your configs in here.
- `class_configs`: Configs that apply to a certain class of machine.
For example "server", "desktop", or "work".
You can create any custom classes you want.
- `sys_specific_configs`: Configs that are specific to a single system or
machine.
Systems are identified by their hostname.

Each config category contains one or more config modules.
For example the class category contains three modules `desktop`, `personal`, and
`server`.
Each module is broken down into the following structure:

- `config_container/`
    - `config_module/`
        - `home/`
            - [config files relative to $HOME]
        - `root/`
            - [config files relative to root]
        - `dotfile_config/`
            - class.txt
            - apt_packages.txt
            - debconf_selections.txt
            - install.bash
            - configure.bash

All configs can be placed in either the home or root folders and will be
symlinked accordingly.
The `dotfile_config` folder contains settings and additional customization
scripts if needed.

**class.txt**: This file is placed in the `sys_specific_configs` and contains a
list of all the classes that the machine belongs to.  
**apt_packages.txt**: Contains a list of all packages to be installed via
`apt`.  
**debconf_selections.txt**: Contains any debconf commands to be set via
`debconf-set-selections`.  
**install.bash**: This script is run after the main install script.
Place any [custom install commands](https://github.com/icolwell/install_scripts)
here.  
**configure.bash**: This script is run after the main configure script.
Place any custom configuration commands here.

### Additional Notes on Structure
Since all user configs reside somewhere under your `$HOME` directory,
the `config_module/home/` folder in this repo contains all configs relative to
the `$HOME` directory.
This means a script can simply loop over all the files found in the
`config_module/home/` folder and know where to symlink them relative to your
`$HOME` directory.
System wide configs are handled the same way.
These are stored in the `config_module/root` folder and are symlinked relative
to root (`/`).

Another benefit is
that you can easily separate private configs (such as your `.ssh/config`) by
simply storing them in another location with the same folder structure (Dropbox
for example).
The `scripts/settings.bash` file is where to set the location of any other
private config containers.

## Scripts

See the [scripts README](scripts/README.md) for an explanation of the scripts.

## Continuous Integration Testing

A [docker image](https://hub.docker.com/r/iancolwell/xenial_desktop/)
that emulates a typical Ubuntu 16.04 desktop installation is used to
verify that all the installation scripts work as expected.

The CI build logs can be found
[here](https://circleci.com/gh/icolwell/dotfiles).
