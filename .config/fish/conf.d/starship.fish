if status is-interactive; and command -q starship
    # a per-machine config wins, like ~/.bashrc.local
    if test -f ~/.config/starship.local.toml
        set -gx STARSHIP_CONFIG ~/.config/starship.local.toml
    end
    starship init fish | source
end
