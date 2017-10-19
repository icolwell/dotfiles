#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

terminal_coloring()
{
	WHITE="\[\033[1;37m\]"
	RED="\[\033[1;31m\]"
	GREEN="\[\033[1;32m\]"
	BLUE="\[\033[1;34m\]"
	LIGHT_BLUE="\[\033[1;94m\]"
	ORANGE="\[\033[38;5;208m\]"
	NO_CLR="\[\033[0m\]"

	# set a fancy prompt (non-color, unless we know we "want" color)
	case "$TERM" in
		xterm-color) color_prompt=yes;;
	esac

	# uncomment for a colored prompt, if the terminal has the capability; turned
	# off by default to not distract the user: the focus in a terminal window
	# should be on the output of commands, not on the prompt
	force_color_prompt=yes

	if [ -n "$force_color_prompt" ]; then
		if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
			# We have color support; assume it's compliant with Ecma-48
			# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
			# a case would tend to support setf rather than setaf.)
			color_prompt=yes
		else
			color_prompt=
		fi
	fi

	# If this is an xterm set the title to user@host:dir
	case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
	esac

	if [ "$color_prompt" = yes ]; then
		PS1="${debian_chroot:+($debian_chroot)}$ORANGE\u$NO_CLR@$ORANGE\h$NO_CLR:\W$GREEN\$(parse_git_branch)$NO_CLR\$ "
	else
		PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W$(parse_git_branch)\$ '
	fi
	unset color_prompt force_color_prompt

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls='ls --color=auto'
		alias dir='dir --color=auto'
		alias vdir='vdir --color=auto'
		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi
}

# Git colored terminal branch indicator
parse_git_branch()
{
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

define_aliases()
{
	# Add an "alert" alias for long running commands.  Use like so:
	#   sleep 10; alert
	alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

	source_file ~/.bash_aliases

	# ls aliases
	alias ll='ls -alF'
	alias la='ls -A'
	alias l='ls -CF'

	# apt-get aliases
	alias update='sudo apt-get update'
	alias install='sudo apt-get install'
	alias upgrade='update && sudo apt-get upgrade'

	# git aliases
	alias gits='git status'
	alias gita='git add -A . && git status'
	alias gitc='git commit -m'
	alias gitp='git pull'

	# mercurial aliases
	alias hgs='hg sum'
	alias hga='hg add && hg sum'
	alias hgc='hg commit -m'
	alias hgp='hg pull'

	# TMUX
	alias tmux='tmux -2'

	# ROS
	alias cws='cd ~/catkin_ws/src'
	alias catb='(cd ~/catkin_ws && catkin build)'
	alias catc='(cd ~/catkin_ws && catkin clean -y)'

	# Other
	alias clang++=clang++-3.5
	alias clang=clang-3.5
	alias sbrc='source ~/.bashrc'
	alias clr='clear'
}

application_specific()
{
	# ROS
	source_file /opt/ros/kinetic/setup.bash
	source_file ~/catkin_ws/devel/setup.bash
	export QNXROS_WS="$HOME/qnx_catkin_ws"
	source_file ~/autonomoose/renesas-demo/scripts/qnx/qnxros.bash

	# anm_sim
	source_file ~/autonomoose/anm_sim/vrep_test_suite/scripts/test_suite_lib.bash

	# V-REP
	export VREP_ROOT=$HOME/opt/vrep/V-REP_PRO_EDU_V3_4_0_Linux

	# GO
	export GOPATH=$HOME/gocode
	PATH=$PATH:/usr/local/go/bin

	# cabal
	PATH="$PATH:$HOME/.cabal/bin"

	# pip packages
	PATH=$PATH:~/.local/bin

	# Other
	[ -f ~/.fzf.bash ] && source ~/.fzf.bash

	export PATH
}

source_file()
{
	if [ -f "$1" ]; then
		source "$1"
	fi
}

terminal_coloring
define_aliases
application_specific

# Anything after this line was added automatically by some script
