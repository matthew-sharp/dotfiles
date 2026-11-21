if test -f ~/.aliases
    # source ~/.aliases with alias also adding a matching abbr, so they
    # expand on space; the aliases stay too, since abbrs don't nest (gca -> gc -a)
    functions --copy alias __real_alias
    function alias
        set -l kv (string split -m 1 = -- $argv[1])
        abbr --add -- $kv[1] $kv[2]
        __real_alias $argv
    end
    source ~/.aliases
    functions --erase alias
    functions --copy __real_alias alias
    functions --erase __real_alias
end
