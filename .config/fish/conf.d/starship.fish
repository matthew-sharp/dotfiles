# Shared dotfile: linked from ~/dotfiles by setup.sh, applies to every machine.
# For per-machine setup add an untracked file to ~/.config/fish/conf.d/ (for the
# prompt itself, see starship.toml); only edit here for changes all machines
# should get.

if status is-interactive; and command -q starship
    # a per-machine config wins, like ~/.bashrc.local
    if test -f ~/.config/starship.local.toml
        set -gx STARSHIP_CONFIG ~/.config/starship.local.toml
    end
    starship init fish | source
end
