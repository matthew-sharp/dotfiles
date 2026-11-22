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
