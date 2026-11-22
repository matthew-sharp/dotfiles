# user@host · date · uptime, then other login sessions and failed units.
# Each part is skipped where its tool isn't available (e.g. macOS).
function fish_greeting
    set -l line (set_color --bold blue)$USER(set_color normal)@(set_color --bold green)$hostname(set_color normal)
    set -a line (date '+%a %-d %b %Y %H:%M')
    if command -q uptime
        set -l up (uptime -p 2>/dev/null | string replace -r '^up ' '')
        and set -a line "up $up"
    end
    echo (string join ' · ' $line)

    # other sessions, grouped by user, not counting this one
    set -l others
    if command -q loginctl
        set others (loginctl list-sessions --no-legend 2>/dev/null \
            | awk -v me="$XDG_SESSION_ID" '$1 != me && $6 == "user" { print $3 }')
    else if command -q who
        set others (who | awk '{ print $1 }')
        set -e others[(contains -i -- $USER $others)]
    end
    if set -q others[1]
        set -l counts
        for u in (printf '%s\n' $others | sort -u)
            set -a counts "$u ("(count (string match -- $u $others))")"
        end
        echo "Also logged in: "(string join ', ' $counts)
    end

    if command -q systemctl
        set -l failed (systemctl --failed --no-legend --plain 2>/dev/null | awk '{ print $1 }')
        set -a failed (systemctl --user --failed --no-legend --plain 2>/dev/null | awk '{ print $1 "(user)" }')
        if set -q failed[1]
            set_color red
            echo "Failed units ("(count $failed)"): "(string join ', ' $failed)
            set_color normal
        end
    end
end
