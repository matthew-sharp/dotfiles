#!/bin/sh

git_config_command="git config --global"

${git_config_command} push.default upstream
${git_config_command} core.editor vim
${git_config_command} color.ui auto

