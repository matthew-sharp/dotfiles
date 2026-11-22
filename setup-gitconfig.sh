#!/bin/sh

git_config_command="git config --global"

${git_config_command} push.default upstream
# without hx, leave git to its default ($GIT_EDITOR, $VISUAL, $EDITOR, then vi)
if command -v hx >/dev/null; then
    ${git_config_command} core.editor hx
fi
${git_config_command} color.ui auto
