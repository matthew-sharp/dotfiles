#!/bin/sh
# Move uncommitted additions to .bashrc and .profile into ~/.bashrc.local and
# ~/.profile.local, then restore the repo's copy.
# Installers (conda, nvm, rustup, the gcloud SDK, ...) append to ~/.bashrc and
# ~/.profile, which are links into this repo, and their lines land after the
# point where .bashrc execs fish, so they never run there.
# -n: only show what would be moved

basedir="$( cd "$( dirname "$0" )" && pwd )"

dry_run=
if [ "$1" = -n ]; then
    dry_run=1
fi

cd "$basedir" || exit 1

status=0
moved=
for file in .bashrc .profile; do
    git diff --quiet HEAD -- "$file" && continue

    # only pure additions can be moved safely; edits to existing lines need a person
    if [ "$(git diff --numstat HEAD -- "$file" | cut -f 2)" != 0 ]; then
        echo "$file: changes edit or remove existing lines, move them by hand:" >&2
        git diff HEAD -- "$file" >&2
        status=1
        continue
    fi

    local_file="$HOME/$file.local"
    added=$(git diff -U0 HEAD -- "$file" \
        | awk '/^@@/ { hunk = 1; next } hunk && /^\+/ { print substr($0, 2) }')
    echo "$file -> $local_file:"
    printf '%s\n' "$added" | sed 's/^/    /'
    [ -n "$dry_run" ] && continue

    # keep the appended block on its own lines
    if [ -s "$local_file" ]; then
        [ -n "$(tail -c 1 "$local_file")" ] && echo >> "$local_file"
        echo >> "$local_file"
    fi
    {
        echo "# moved from $file in dotfiles on $(date +%Y-%m-%d)"
        printf '%s\n' "$added"
    } >> "$local_file" && git checkout HEAD -- "$file" || status=1
    moved=1
done

others=$(git diff --name-only HEAD | grep -v -x -e .bashrc -e .profile)
if [ -n "$others" ]; then
    echo "Not handled, these have no .local file:" >&2
    printf '%s\n' "$others" | sed 's/^/    /' >&2
fi

if [ -n "$moved" ]; then
    echo "Moved lines run in bash before it hands over to fish: exported variables carry over,"
    echo "but shell functions and hooks don't, so tools like conda need their fish setup too (conda init fish)."
fi

exit $status
