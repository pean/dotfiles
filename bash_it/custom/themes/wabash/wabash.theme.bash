#!/usr/bin/env bash

SCM_GIT_SHOW_DETAILS=false
SCM_GIT_SHOW_DETAILS=false
SCM_GIT_SHOW_REMOTE_INFO=false
SCM_GIT_IGNORE_UNTRACKED=false


SCM_THEME_PROMPT_PREFIX="${cyan}${green} ("
SCM_THEME_PROMPT_SUFFIX="${cyan})"
# SCM_THEME_PROMPT_DIRTY=" ${red}X"
# SCM_THEME_PROMPT_CLEAN=" ${green}V"
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"

prompt() {
  PS1="\h:${cyan}\W${reset_color}$(scm_prompt_info)${reset_color}$ "
}

safe_append_prompt_command prompt
