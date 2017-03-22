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
link_file .git-prompt-colors.sh
link_file .vim
link_file .bash-git-prompt

${basedir}/setup-gitconfig.sh

