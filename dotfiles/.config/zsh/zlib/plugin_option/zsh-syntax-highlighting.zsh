ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
#ZSH_HIGHLIGHT_STYLES[comment]="fg=59,bold"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp cursor)
# Highlight known abbrevations
typeset -A ZSH_HIGHLIGHT_REGEXP
ZSH_HIGHLIGHT_REGEXP+=('(^| )('${(j:|:)${(k)ABBR_REGULAR_USER_ABBREVIATIONS}}')($| )' 'fg=blue')
