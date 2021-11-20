#_zsh-history-substring-search-setting() {
#  bindkey "^[[A" history-substring-search-up
#  bindkey "^[[B" history-substring-search-down
#  bindkey "$terminfo[kcuu1]" history-substring-search-up
#  bindkey "$terminfo[kcud1]" history-substring-search-down
#  HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
#}

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white'
HISTORY_SUBSTRING_SEARCH_FUZZY=1
bindkey "${key[Up]}"   history-substring-search-up
bindkey "${key[Down]}" history-substring-search-down
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
