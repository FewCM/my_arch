#!/usr/bin/env bash
#
# 


function has() {
  which "$@" > /dev/null 2>&1
}

export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude '.git' --exclude 'node_modules'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
    
export FZF_DEFAULT_OPTS="--layout=reverse
	--info=inline
	--height=80%
	--multi
	--cycle
	--border
	--preview window=:hidden
	--color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D,gutter:$color01
	--color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
	--color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
	--prompt='λ -> ' --pointer='|>' --marker='✓'
	--bind '?:toggle-preview'
	--bind 'ctrl-a:select-all'
	--bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
	--bind 'ctrl-v:execute(code {+})'
"

if has bat; then
  # bat will syntax colorize files for you
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) ||  ([[ -d {} ]] && (exa --oneline --long --header --color=always --icons --group-directories-first {})) || echo {} 2> /dev/null | head -200'"
fi

export FZF_PREVIEW_COMMAND="bat --style=numbers,changes --wrap character --color always {} || cat {} || exa --oneline --long --header --color=always --icons --group-directories-first {} || tree -C {}"


if has pbcopy; then
  # on macOS, make ^Y yank the selection to the system clipboard
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'"
fi
  
if has tree; then
 function fzf-change-directory() {
    local directory=$(
      fd --type d | \
      fzf --query="$1" --no-multi --select-1 --exit-0 \
        --preview 'tree -C {} | head -100'
      )
    if [[ -n "$directory" ]]; then
      cd "$directory"
    fi
  }
  alias fcd=fzf-change-directory
fi

#if has z; then
#  unalias z 2> /dev/null
  # like normal z when used with arguments but displays an fzf prompt when used without.
#  function z() {
#    [ $# -gt 0 ] && _z "$*" && return
#    cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
#  }
#fi

# From fzf wiki
# cdf - cd into the directory of the selected file
function cdf() {
  local file
  local dir
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

# Cleanup internal functions
unset -f has

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
