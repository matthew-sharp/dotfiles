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
link_file .config/fish/functions/fish_greeting.fish

${basedir}/setup-gitconfig.sh

# report optional tools that aren't installed, and what goes without them
missing=()

function check_command {
    local cmd=$1 why=$2
    command -v "$cmd" >/dev/null || missing+=("$cmd: $why")
}

check_command fish "terminals stay in bash"
check_command starship "plain default prompt"
if ! command -v zoxide >/dev/null && ! command -v autojump >/dev/null; then
    missing+=("zoxide (or autojump): no directory jumping")
fi
check_command hx "git uses its default editor (rerun setup-gitconfig.sh once installed)"
if [[ ! -f /usr/share/bash-completion/bash_completion && ! -f /etc/bash_completion ]]; then
    missing+=("bash-completion: only basic tab completion in bash")
fi

if (( ${#missing[@]} )); then
    echo "Not installed:"
    printf '    %s\n' "${missing[@]}"
fi

