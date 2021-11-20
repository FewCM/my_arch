# fzf-tab
# disable sort when completing options of any command
zstyle ':completion:complete:*:options' sort false

# use input as query string when completing zlua
zstyle ':fzf-tab:complete:_zlua:*' query-string prefix input first

#zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview ' 
#	exa --oneline --long --header --color=always --icons --group-directories-first $realpath 
#'
#zstyle ':fzf-tab:complete:(nvim|vim|micro|nano):*' fzf-preview '
#	bat --style=numbers --color=always --line-range :250 $realpath 2>/dev/null
#'

# 预览 systemctl 状态
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'

#show file contents
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
export LESSOPEN='|~/.config/zsh/lessfilter %s'

zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'exa --color=always -aT -L=2 --group-directories-first --git -I=.git $realpath'
  
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
  'echo ${(P)word}'
  
# environment variable
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
	
zstyle ':fzf-tab:*' single-group ''

