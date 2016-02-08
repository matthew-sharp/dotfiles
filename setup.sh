#!/bin/bash

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function link_file {
    ln -si "$basedir"/"$1" ~
}

link_file .profile
link_file .bashrc
link_file .aliases

${basedir}/setup-gitconfig.sh

