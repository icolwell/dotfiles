# dotfiles

This repo contains scripts to automatically install applications and configure
both the desktop and terminal environment. The two main goals of this repo are:
1. To be able to install a fresh copy of Ubuntu and then simply run a single
script to set everything up "the way it was before".
2. To backup configurations and sync them across multiple systems.

Additional Features
- Automatic installation of all your apps.
- easy support for host-specific configs.
- debconf preconfiguration for apps requiring user input during installation.

NOTE: These dotfiles and scripts have only been tested on Ubuntu 16.04. It is
possible that they no longer work for 14.04 or other versions.

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
It's really quite simple.

\* You can simply clone my repo without forking if you just want to get up and
running fast.

## Customizing this dotfiles repo to your own preferences

If you want to use this repo for your own dotfiles feel free to fork or copy.
You will most likely want to modify at least the following things although it is
totally optional of course:

- `configs` folder to contain your configs (or just use mine)
- configure_desktop.bash
    - `PRIVATE_CONFIGS_DIR` and `SYSTEM_CONFIGS_DIR` variables to point towards
        your private or system-specific configs directory (or just remove)
    - Any app-specific config functions above the comment line
- install_apps.bash
    - All the `APPS` variables at the very top
    - The `repository_additions` function
    - The `default_install` function to add or remove custom installs

## Folder Structure

I designed the folder structure to be as simple as possible. Since all user
configs reside somewhere under your `$HOME` directory, the `configs/home` folder
in this repo contains all configs relative to the `$HOME` directory. This means
a script can simply loop over all the files found in the `configs/home` folder
and know where to symlink them relative to your `$HOME` directory. System wide
configs are handled the same way. These are stored in the `configs/root` folder
and are symlinked relative to root (`/`).

Another benefit is
that you can easily separate private configs (such as your `.ssh/config`) by
simply storing them in another location with the same folder structure (Dropbox
for example). System-specific configs can also be handled by providing a path
based on an assumed unique hostname.

## Scripts

See the [scripts README](scripts/README.md) for an explanation of the scripts.

## Continuous Integration Testing

A [docker image](https://hub.docker.com/r/iancolwell/xenial_user/)
that emulates a typical Ubuntu 16.04 desktop installation is used to
verify that all the installation scripts work as expected.

The CI build logs can be found
[here](https://circleci.com/gh/icolwell/dotfiles).
