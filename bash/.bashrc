PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOME}/.bash.d
export PATH

EDITOR=nano
export EDITOR

# Load colors
[ -f ~/.bash_colors ] && source ~/.bash_colors

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

function myprompt () {
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
    fi

    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$TERM" in
	xterm-color) color_prompt=yes;;
    esac

    force_color_prompt=yes
    if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	    color_prompt=yes
	else
	    color_prompt=
	fi
    fi

    if [ "$color_prompt" = yes ]; then
	export PS1="\[$BRed\]\t\[$Color_Off\]–\[$BGreen\]\u\[$BPurple\]@\[$BCyan\]\h:\[$BWhite\] \w \[\033[0;32m\][$(__git_ps1) ]\[$BYellow\] $\[$Color_Off\] "
    else
	export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
    unset color_prompt force_color_prompt

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
	xterm*|rxvt*)
	    export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	    ;;
	*)
	    ;;
    esac
}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Load aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# Completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

ssh-reagent
export BROWSER="firefox"

# Git-subrepo
source /home/loic/Software/git-subrepo/.rc
source /home/loic/Software/git-subrepo/share/git-completion.bash
source /home/loic/Software/git-subrepo/share/completion.bash

# Git Prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
source /usr/share/git/git-prompt.sh

# Set PROMPT
export PROMPT_COMMAND="myprompt"
