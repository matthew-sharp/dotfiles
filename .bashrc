# ~/.bashrc: executed by bash(1) for non-login shells.

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
shopt -s globstar 2>/dev/null

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && lesspipe | grep -q 'export' && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability
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

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# before ~/.aliases, so its l/ll/la (eza where installed) build on this
if ls --color=auto >/dev/null 2>&1 ; then
    alias ls="ls --color=auto -F"
else
    alias ls="ls -GF"
fi

if command -v starship >/dev/null 2>&1; then
    # a per-machine config wins, like ~/.bashrc.local
    if [ -f ~/.config/starship.local.toml ]; then
        export STARSHIP_CONFIG=~/.config/starship.local.toml
    fi
    eval "$(starship init bash)"
fi

if [ -f ~/.aliases ]; then
    # skip aliases whose command isn't available on this machine
    alias() {
        local arg value
        for arg; do
            if [[ $arg == *=* ]]; then
                value=${arg#*=}
                command -v "${value%% *}" >/dev/null || continue
            fi
            builtin alias "$arg"
        done
    }
    . ~/.aliases
    # per-machine aliases, kept out of the repo like ~/.bashrc.local
    [ -f ~/.aliases.local ] && . ~/.aliases.local
    unset -f alias
fi

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

# complete the git aliases from ~/.aliases like the git subcommands they wrap
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

if declare -F __git_complete >/dev/null; then
    __git_complete g __git_main
    __git_complete gst _git_status
    __git_complete gd _git_diff
    __git_complete gsta _git_stash
    __git_complete gc _git_commit
    __git_complete gca _git_commit
    __git_complete gc! _git_commit
    __git_complete gca! _git_commit
    __git_complete ga _git_add
    __git_complete gco _git_checkout
    __git_complete gr _git_reset
    __git_complete gp _git_push
    __git_complete gpsu _git_push
    __git_complete gf _git_fetch
    __git_complete gl _git_pull
    __git_complete grb _git_rebase
fi

if [ -r /usr/share/autojump/autojump.bash ]; then
    . /usr/share/autojump/autojump.bash
fi

if [ -f /usr/local/etc/autojump.sh ]; then
    . /usr/local/etc/autojump.sh
fi

if command -v zoxide >/dev/null; then
    eval "$(zoxide init bash)"
fi

umask 027

if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi

# hand interactive terminals to fish; leave bash -c, scripts and shells started
# from another shell alone, but not tmux/screen panes (SHLVL is >1 there)
# (set no_fish=1 in ~/.bashrc.local, or e.g. `no_fish=1 bash`, to stay in bash)
# (stay in bash if the parent can't be identified, e.g. no /proc and no ps)
# The handoff waits for the first prompt so everything after this point runs
# first and its exports reach fish: lines installers append to ~/.bashrc, and
# the rest of a wrapper ~/.bashrc that sources this file (see setup.sh).
__fish_handoff() {
    local status=$? parent_comm=
    # one-shot: drop the hook, and leave a no-op for any copy of PROMPT_COMMAND
    # another tool took (e.g. VS Code shell integration wraps it)
    PROMPT_COMMAND=${PROMPT_COMMAND//__fish_handoff/}
    __fish_handoff() { return $?; }
    read -r parent_comm 2>/dev/null </proc/$PPID/comm \
        || parent_comm=$(ps -o comm= -p $PPID 2>/dev/null)
    if [[ -z $no_fish && -n $parent_comm ]] \
            && [[ ! $parent_comm =~ ^(fish|bash|sh|zsh)$ ]] \
            && command -v fish >/dev/null; then
        shopt -q login_shell && exec fish --login || exec fish
    fi
    return $status
}
# last, so hooks before it (starship, zoxide) still see the command's $?;
# a newline rather than ';' in case PROMPT_COMMAND already ends in one
if [[ -z $BASH_EXECUTION_STRING ]]; then
    if [[ -n $PROMPT_COMMAND ]]; then
        PROMPT_COMMAND+=$'\n__fish_handoff'
    else
        PROMPT_COMMAND=__fish_handoff
    fi
fi
