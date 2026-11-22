# user@host · date · uptime · memory, then other login sessions, a pending
# reboot, nearly full filesystems and failed units.
# Each part is skipped where its tool isn't available (e.g. macOS).
function fish_greeting
    set -l line (set_color --bold blue)$USER(set_color normal)@(set_color --bold green)$hostname(set_color normal)
    set -a line (date '+%a %-d %b %Y %H:%M')
    if command -q uptime
        set -l up (uptime -p 2>/dev/null | string replace -r '^up ' '')
        and set -a line "up $up"
    end
    if test -r /proc/meminfo
        set -l kb (awk '$1 == "MemAvailable:" || $1 == "MemTotal:" { print $2 }' /proc/meminfo)
        set -a line (math -s1 $kb[2] / 1048576)/(math -s1 $kb[1] / 1048576)" GiB free"
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

    # a newer kernel of the same flavour (e.g. -cachyos-bore) is installed,
    # or the running kernel's modules have been removed
    set -l running (uname -r)
    if test -d /lib/modules
        set -l flavour (string replace -r '^[0-9.]+(-[pr][0-9]+)?' '' -- $running)
        set -l newest (path basename /lib/modules/*$flavour | sort -V | tail -n 1)
        set -l reboot
        if not test -d /lib/modules/$running
            set reboot "modules for the running kernel ($running) are gone"
        else if test "$newest" != $running
            set reboot "running $running, $newest installed"
        end
        if set -q reboot[1]
            set_color yellow
            echo "Reboot pending: $reboot"
            set_color normal
        end
    end

    # local filesystems at 90% or more, each device once (btrfs subvolumes share one)
    set -l full (df -l --output=source,fstype,pcent,target 2>/dev/null \
        | awk 'NR > 1 && $2 !~ /^(devtmpfs|efivarfs)$/ && $4 !~ "^/(run|dev)(/|$)" && !seen[$1]++ \
            && $3 + 0 >= 90 { print $4 " " $3 }')
    if set -q full[1]
        set_color yellow
        echo "Nearly full: "(string join ', ' $full)
        set_color normal
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
