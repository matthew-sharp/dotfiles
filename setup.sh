#!/bin/bash

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function link_file {
    local file=$1
    if [[ ! -L ~/"${file}" ]]; then
	mkdir -p ~/"$(dirname "${file}")"
	ln -si "$basedir/${file}" ~/"$(dirname "${file}")"
    fi
}

link_file .profile
link_file .bashrc
link_file .aliases
link_file .vim
link_file .vimrc
link_file .config/starship.toml
link_file .config/fish/conf.d/aliases.fish
link_file .config/fish/conf.d/starship.fish
link_file .config/fish/conf.d/jump.fish

${basedir}/setup-gitconfig.sh

