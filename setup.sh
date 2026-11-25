#!/bin/bash

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function link_file {
    local file=$1
    if [[ ! -L ~/"${file}" ]]; then
	mkdir -p ~/"$(dirname "${file}")"
	ln -si "$basedir/${file}" ~/"$(dirname "${file}")"
    fi
}

# ~/.bashrc as a real file that sources the repo's copy, for machines that
# rewrite ~/.bashrc themselves: their lines land in it rather than in the repo
function wrap_bashrc {
    local source_line=". \"$basedir/.bashrc\""
    if [[ -L ~/.bashrc && $(readlink ~/.bashrc) == "$basedir/.bashrc" ]]; then
        rm ~/.bashrc
    fi
    if [[ ! -e ~/.bashrc ]]; then
        cat > ~/.bashrc <<EOF
# Something on this machine rewrites ~/.bashrc, so this is a real file rather
# than a link into dotfiles (written by dotfiles/setup.sh). The shared config
# is sourced below; anything appended after it belongs to this machine only.

# here as well as in the repo's copy: a return in a sourced file only leaves
# that file, and appended lines must not run in non-interactive shells
case \$- in
    *i*) ;;
      *) return;;
esac

$source_line
EOF
    elif ! grep -qxF "$source_line" ~/.bashrc; then
        echo "~/.bashrc is not a wrapper for this repo; to make it one, move it aside and rerun." >&2
    fi
}

link_file .profile
# Cloud Workstation boot scripts (/etc/workstation-startup.d) append to
# ~/.bashrc on every boot; DOTFILES_WRAP_BASHRC=1 or 0 overrides the detection
wrap=${DOTFILES_WRAP_BASHRC-}
if [[ -z $wrap && -d /etc/workstation-startup.d ]]; then
    wrap=1
fi
if [[ $wrap == 1 ]]; then
    wrap_bashrc
else
    link_file .bashrc
fi
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
check_command eza "l/ll/la/lal/t use plain ls and tree"
check_command hx "git uses its default editor (rerun setup-gitconfig.sh once installed)"
if [[ ! -f /usr/share/bash-completion/bash_completion && ! -f /etc/bash_completion ]]; then
    missing+=("bash-completion: only basic tab completion in bash")
fi

if (( ${#missing[@]} )); then
    echo "Not installed:"
    printf '    %s\n' "${missing[@]}"
fi

