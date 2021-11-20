# The zsh/complist module offers three extensions to completion listings:
#     the ability to high-light matches in such a list ($ZLS_COLORS or :list-colors)
#     the ability to scroll through long lists  ($LISTPROMPT or :listprompt)
#     a different style of menu completion. (select, auto_menu)
#zmodload -i zsh/complist

WORDCHARS=''

setopt auto_list
setopt auto_menu
setopt always_to_end
#setopt COMPLETE_ALIASES

# Basic autocomplete with: menu-listing, hyphen- and case-insensitivity, accepts abbreviations after . or _ or - (ie. f.b -> foo.bar), substring complete (ie. bar -> foobar), and colored with LS_COLORS.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# If you end up using a directory as argument, this will remove the trailing slash (usefull in ln)
zstyle ':completion:*' squeeze-slashes true
# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions
# Kill
#zstyle ':completion:*:*:*:*:processes' command 'ps -uf'
#zstyle ':completion:*:*:*:*:processes*' force-list always
#zstyle ':completion:*:processes-names'     command "ps -eo cmd= | sed 's:\([^ ]*\).*:\1:;s:\(/[^ ]*/\)::;/^\[/d'"
#zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
#zstyle ':completion:*:*:kill:*' menu yes # same thing as below but for kill processes completion
# History
## When using history-complete-(newer/older), complete with the first item on the first request (as opposed to 'menu select' which only shows the menu on the first request)
## NOTE: this uses Alt+/ backwards, Alt+, forwards, and Alt+.
zstyle ':completion:history-words:*' menu yes
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single
# offer completions for directories from all these groups
zstyle ':completion:*::*:(cd|pushd):*' tag-order local-directories directory-stack path-directories
# never offer the parent directory (e.g.: cd ../<TAB>)
zstyle ':completion:*:cd:*' ignore-parents parent pwd
# don't complete things which aren't available, such as the many zsh functions starting with an underscore.
zstyle ':completion:*:*:-command-:*:*' tag-order 'functions:-non-comp *' functions
zstyle ':completion:*:functions-non-comp' ignored-patterns '_*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
# complete sudo commands
zstyle ':completion::complete:*' gain-privileges 1
# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
    dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
    hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
    mailman mailnull mldonkey mysql nagios \
    named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
    operator pcap postfix postgres privoxy pulse pvm quagga radvd \
    rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# run rehash on completion so new installed program are found automatically:
_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1 # Because we didn't really complete anything
}

## Prevent CVS files/directories from being completed
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'


# some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
if [[ -n "$NOCOR" ]] ; then
  zstyle ':completion:*'                            completer _oldlist _expand _force_rehash _complete _files
  setopt nocorrect # do not try to correct the spelling if possible
else
  #    zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _correct _approximate _files
  setopt correct  # try to correct the spelling if possible
  zstyle -e ':completion:*'                         completer '
  if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]]; then
    _last_try="$HISTNO$BUFFER$CURSOR"
    reply=(_complete _match _prefix _files)
  else
    if [[ $words[1] = (rm|mv) ]]; then
      reply=(_complete _files)
    else
      reply=(_oldlist _expand _force_rehash _complete _correct _approximate _files)
    fi
  fi'
fi

## completion stuff
zstyle ':compinstall' filename '$ZDOTDIR/.zshrc'

# initialization
_zpcompinit_custom() {
  setopt extendedglob local_options
  autoload -Uz compinit
  local zcd=${ZPLGM[ZCOMPDUMP_PATH]:-${ZDOTDIR:-$HOME}/.zcompdump}
  local zcdc="$zcd.zwc"
  # Compile the completion dump to increase startup speed, if dump is newer or doesn't exist,
  # in the background as this is doesn't affect the current session
  if [[ -f "$zcd"(#qN.m+1) ]]; then
        compinit -i -d "$zcd"
        { rm -f "$zcdc" && zcompile "$zcd" } &!
  else
        compinit -C -d "$zcd"
        { [[ ! -f "$zcdc" || "$zcd" -nt "$zcdc" ]] && rm -f "$zcdc" && zcompile "$zcd" } &!
  fi
}
