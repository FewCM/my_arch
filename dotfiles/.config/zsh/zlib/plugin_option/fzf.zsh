export FZF_SIZER_HORIZONTAL_PREVIEW_PERCENT_CALCULATION='max(60, min(80, 100 - ((7000 + (11 * __WIDTH__))  / __WIDTH__)))'
export FZF_SIZER_VERTICAL_PREVIEW_PERCENT_CALCULATION='max(60, min(80, 100 - ((3000 + (5 * __HEIGHT__)) / __HEIGHT__)))'


_gen_fzf_default_opts() {

local color00='#282828'
local color01='#3c3836'
local color02='#504945'
local color03='#665c54'
local color04='#bdae93'
local color05='#d5c4a1'
local color06='#ebdbb2'
local color07='#fbf1c7'
local color08='#fb4934'
local color09='#fe8019'
local color0A='#fabd2f'
local color0B='#b8bb26'
local color0C='#8ec07c'
local color0D='#83a598'
local color0E='#d3869b'
local color0F='#d65d0e'

export FZF_DEFAULT_COLOR=" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"

}
_gen_fzf_default_opts

export FZF_DEFAULT_BASIC=" --layout=reverse
--border 
--pointer='» '
--marker='◈ ' 
--multi 
--cycle 
--bind '?:toggle-preview' 
--bind 'ctrl-a:select-all'
--bind 'ctrl-e:execute(echo {+} | xargs -o vim)' 
--bind 'ctrl-v:execute(code {+})' 
--no-height
"

export FZF_PREVIEW_COMMAND="--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) ||  ([[ -d {} ]] && (exa --oneline --long --header --color=always --icons --group-directories-first {})) || echo {} 2> /dev/null | head -200' || [[ $(file --mime {}) =~ binary ]] && echo {} is a binary file"

export FZF_DEFAULT_OPTS_MULTI="\
  --bind alt-d:deselect-all \
  --bind alt-a:select-all"


export FZF_DEFAULT_OPTS="\
	$FZF_DEFAULT_COLOR \
    $FZF_DEFAULT_BASIC \

    $(fzf_sizer_preview_window_settings)"
  
# $FZF_PREVIEW_COMMAND \
  
# Use `fd` instead of the default find command for listing path candidates.
   _fzf_compgen_path() {
     fd --hidden --follow . "$1"
   }

# Use `fd` to generate the list for directory completion
   _fzf_compgen_dir() {
     fd --type d --hidden --follow . "$1"
   }

# use `fd`
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude '.git' --exclude 'node_modules' --ignore-file ~/.gitignore"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"


export DIR_PREVIEW_COMMAND='exa --icons --color=always -l --color-scale --classify --sort=type --git'
# use `ls` to preview directories
export FZF_ALT_C_OPTS="--preview='$DIR_PREVIEW_COMMAND'"

# binary -> display indication of this
# directory -> use `$DIR_PREVIEW_COMMAND`
# files -> `bat` is installed on all my machines
export FZF_CTRL_T_OPTS='--preview='"'"'[[ $(file --mime {}) =~ binary ]] &&
                                           echo {} is a binary file ||
                                         [[ $(file --mime {}) =~ directory ]] &&
                                           '"$DIR_PREVIEW_COMMAND"' {} ||
                                         bat --style=numbers --color=always {}'"'"
