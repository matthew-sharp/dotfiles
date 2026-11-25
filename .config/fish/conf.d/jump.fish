# Shared dotfile: linked from ~/dotfiles by setup.sh, applies to every machine.
# For per-machine setup add an untracked file to ~/.config/fish/conf.d/; only
# edit here for changes all machines should get.

# fish versions of the autojump/zoxide setup in .bashrc
for f in /usr/share/autojump/autojump.fish /usr/local/share/autojump/autojump.fish
    if test -r $f
        source $f
        break
    end
end

if command -q zoxide
    zoxide init fish | source
end
