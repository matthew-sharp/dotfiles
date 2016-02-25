# This is an alternative approach. Single line in git repo.
override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Single_line"

  GIT_PROMPT_START_USER="_LAST_COMMAND_INDICATOR_ ${BoldGreen}${PathShort}${ResetColor}"
  GIT_PROMPT_END_USER="${ResetColor} $ "
  GIT_PROMPT_END_ROOT="${BoldRed} # "
}

reload_git_prompt_colors "Single_line"

