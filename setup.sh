#!/bin/bash

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function link_file {
    local file=$1
    if [[ ! -L ~/"${file}" ]]; then
	ln -si "$basedir/${file}" ~
    fi
}

link_file .profile
link_file .bashrc
link_file .aliases
link_file .vim
link_file .vimrc

mkdir -p ~/.config
if [[ ! -L ~/.config/starship.toml ]]; then
    ln -si "$basedir/.config/starship.toml" ~/.config
fi

${basedir}/setup-gitconfig.sh

