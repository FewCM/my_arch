#!/usr/bin/env bash
#
# 
# fzf-kill - usage: fzf-kill 
# Fuzzy find a process or group of processes, then SIGKILL them. 
# Multi-selection is enabled to allow multiple processes to be selected via the TAB key
fzf-kill() {
  local pid_col
  local pids

  if [[ $(uname) = Linux ]]; then
    pid_col=2
    pids=$(
      ps -f -u "$USER" | sed 1d | fzf --multi | tr -s "[:blank:]" | cut -d' ' -f"$pid_col"
    )
  elif [[ $(uname) = Darwin ]]; then
    pid_col=3;
    pids=$(
      ps -f -u "$USER" | sed 1d | fzf --multi | tr -s "[:blank:]" | cut -d' ' -f"$pid_col"
    )
  elif [[ $(uname) = FreeBSD ]]; then
    pid_col=2
    pids=$(
      ps -axu -U "$USER" | sed 1d | fzf --multi | tr -s "[:blank:]" | cut -d' ' -f"$pid_col"
    )
  else
    echo 'Error: unknown platform'
    return
  fi

  if [[ -n "$pids" ]]; then
    echo "$pids" | xargs kill -9 "$@"
  fi
}

# find-in-file - usage: find-in-file <SEARCH_TERM>
find-in-file() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!";
    return 1;
  fi
  rg --files-with-matches --no-messages "$1" | fzf $FZF_PREVIEW_WINDOW --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}

# fzf_find_edit - usage: fzf_find_edit <SEARCH_TERM>
# Fuzzy find a file, with optional initial file name, and then edit:
# If one file matches then edit immediately
# If multiple files match, or no file name is provided, then open fzf with colorful preview
# If no files match then exit immediately
fzf_find_edit() {
    local file=$(
      fzf --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
      )
    if [[ -n $file ]]; then
        $EDITOR "$file"
    fi
}

# fzf_grep_edit - usage: fzf_grep_edit <SEARCH_TERM>
# Fuzzy find a file, with colorful preview, that contains the supplied term
# then once selected edit it in your preferred editor
# Note, if your EDITOR is Vim or Neovim then you will be automatically scrolled to the selected line.
fzf_grep_edit(){
    if [[ $# == 0 ]]; then
        echo 'Error: search term was not provided.'
        return
    fi
    local match=$(
      rg --color=never --line-number "$1" |
        fzf --no-multi --delimiter : \
            --preview "bat --color=always --line-range {2}: {1}"
      )
    local file=$(echo "$match" | cut -d':' -f1)
    if [[ -n $file ]]; then
        $EDITOR "$file" +$(echo "$match" | cut -d':' -f2)
    fi
}
