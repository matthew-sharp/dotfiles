if test -f ~/.aliases
    # source ~/.aliases with alias also adding a matching abbr, so they
    # expand on space; the aliases stay too, since abbrs don't nest (gca -> gc -a).
    # Aliases whose command isn't available on this machine are skipped.
    functions --copy alias __real_alias
    function alias
        set -l kv (string split -m 1 = -- $argv[1])
        type -q (string split -f 1 ' ' -- $kv[2]); or return 0
        abbr --add -- $kv[1] $kv[2]
        __real_alias $argv
    end
    source ~/.aliases
    # per-machine aliases, kept out of the repo like ~/.bashrc.local
    test -f ~/.aliases.local; and source ~/.aliases.local
    functions --erase alias
    functions --copy __real_alias alias
    functions --erase __real_alias
end
