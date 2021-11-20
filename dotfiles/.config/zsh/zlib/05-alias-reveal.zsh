#!/bin/zsh

local cmd_alias=""

# Reveal Executed Alias
alias_for() {
  [[ $1 =~ '[[:punct:]]' ]] && return
  local search=$(echo "$1" | awk '{print $1;}')
  local found="$( alias $search )"
  if [[ -n $found ]]; then
    found=${found//\\//}                      # Replace backslash with slash
    found=${found%\'}                         # Remove end single quote
    found=${found#"$search='"}                # Remove alias name
    echo "${found}"                           # Return found value
  else
    echo ""
  fi
}

expand_command_line() {
  cmd_alias="$(alias_for $1)"               # Check if there's an alias for the command
  if [[ -n $cmd_alias ]]; then              # If there was
    echo "\e[38;5;240m> ${cmd_alias}\e[0m"  # Print it
  fi
}

pre_validation() {
  [[ $# -eq 0 ]] && return                    # If there's no input, return. Else...
  expand_command_line "$@"
}

autoload -U add-zsh-hook                      # Load the zsh hook module. 
add-zsh-hook preexec pre_validation           # Adds the hook 
