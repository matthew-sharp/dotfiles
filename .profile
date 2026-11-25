# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# the default umask is set in /etc/profile; for setting the umask
umask 027

if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

if command -v hx >/dev/null 2>&1; then
    export EDITOR=hx VISUAL=hx
fi

if [ -f $HOME/.profile.local ]; then
    . $HOME/.profile.local
fi

# keep this last, so .bashrc sees everything set up above (it hands over to fish
# at the first prompt, after the rest of this file has run)
# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

