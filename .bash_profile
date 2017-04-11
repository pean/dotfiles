#!/usr/bin/env bash



# MacPorts Installer addition on 2016-09-22_at_09:30:16: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

eval "$(rbenv init -)"


export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

eval "$(/Users/peter/hemnet/src/hemnet-terminal-command/bin/hemnet init - bash)"
export PATH=/opt/local/bin:/opt/local/sbin:/Users/peter/.rbenv/shims:/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/peter/hemnet/src/hemnet-terminal-command/bin:$PATH
export PATH=/Users/peter/Library/Python/2.7/bin:$PATH

# PostgreSQL/PostGIS
export DYLD_FALLBACK_LIBRARY_PATH=/opt/local/lib/postgresql95:$DYLD_LIBRARY_PATH
export PATH=/opt/local/lib/postgresql95/bin:$PATH


source /opt/local/etc/bash_completion.d/git-completion.bash
# GIT_PS1_SHOWDIRTYSTATE=true
# export PS1='[\u@mbp \w$(__git_ps1)]\$ '

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Default
# PS1='\h:\W \u\$ '
# export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
# export PS1="\u@\h:\W\[\033[32m\]$(parse_git_branch)\[\033[00m\]$ "
# export PS1="\h:\W~\[\033[32m\]$(parse_git_branch)\[\033[00m\]$ "
export PS1="\h:\W$ "


alias vim="nvim"
alias vi="nvim"


export VISUAL=vim
export EDITOR="$VISUAL"






# Path to the bash it configuration
export BASH_IT="/Users/peter/.bash_it"

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='wabash'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Load Bash It
source $BASH_IT/bash_it.sh

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export PATH="/usr/local/opt/icu4c/bin:$PATH"
export PATH="/usr/local/opt/icu4c/sbin:$PATH"
