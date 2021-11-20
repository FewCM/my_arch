#!/bin/zsh
zmodload zsh/zprof 
typeset -F4 SECONDS=0

declare -A ZINIT

export ZINIT[HOME_DIR]="$ZDOTDIR/zinit"
export ZINIT[BIN_DIR]="$ZDOTDIR/zinit/bin"

ZINIT_HOME="${ZINIT_HOME:-${ZPLG_HOME:-${ZDOTDIR:-${HOME}}/zinit}}"
ZINIT_BIN_DIR_NAME="${${ZINIT_BIN_DIR_NAME:-${ZPLG_BIN_DIR_NAME}}:-bin}"

### Added by Zinit's installer
if [[ ! -f "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "${ZINIT_HOME}" && command chmod g-rwX "${ZINIT_HOME}"
    command git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "${ZINIT_HOME}/${ZINIT_BIN_DIR_NAME}/zinit.zsh"

if [[ ! -f "${ZPFX}/share/man/man1/" ]]; then
	mkdir -p "${ZPFX}/share/man/man1/" 
fi

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

zinit ice wait depth'1' lucid
zinit light bigH/auto-sized-fzf

zinit ice wait'0e' multisrc"01-zopts.zsh\
 02-zcomple.zsh 03-zkbd.zsh 04-aliases.zsh\
 05-alias-reveal.zsh 06-functions.zsh 08-autoload.zsh 09-bash.command-not-found"  lucid
zinit light $ZDOTDIR/zlib

# atload"_alias-tip-setting"
# 08-fuzzy_commands.sh

# A binary Zsh module which transparently and automatically compiles sourced scripts
module_path+=( "/home/fewcm/.config/zsh/zinit/bin/zmodules/Src" )
zmodload zdharma/zplugin &>/dev/null

zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”'
zinit light trapd00r/LS_COLORS
#eval $( dircolors -b $HOME/LS_COLORS)

# colors {{{
zinit light 'chrissicool/zsh-256color'
# }}}

zinit ice wait'0a' lucid
zinit light mafredri/zsh-async

zinit ice atload'source $ZDOTDIR/zlib/plugin_option/prompt.zsh' lucid
zinit light spaceship-prompt/spaceship-prompt

zinit ice wait'0a' src"$ZDOTDIR/zlib/plugin_option/zsh-autosuggestions.zsh" atload'!_zsh_autosuggest_start; _zsh_autosuggest_setting' lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'0a' blockf lucid atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions


zinit lucid from'gh-r' as'program' for \
  mv'bat* -> bat' \
  pick'bat/bat' \
  atclone'cp -vf bat/bat.1 "${ZPFX}/share/man/man1"; cp -vf bat/autocomplete/bat.zsh "bat/autocomplete/_bat"' \
  atpull'%atclone' \
  '@sharkdp/bat' 

# FD
zinit ice lucid wait'0b' as"program" from"gh-r" mv"fd* -> fd" pick"fd/fd" atclone'cp -vf fd/fd.1 "${ZPFX}/share/man/man1"' atpull'%atclone'
zinit light sharkdp/fd

# RIPGREP
zinit ice lucid wait'0c' as"program" from"gh-r" mv'ripgrep* -> rg' pick'rg/rg' atclone'cp -vf rg/doc/rg.1 "${ZPFX}/share/man/man1"' atpull'%atclone' 
zinit light BurntSushi/ripgrep

zinit ice wait'0d' atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' lucid     
zinit light hlissner/zsh-autopair 

# FZF
zinit ice wait'0e' lucid from'gh-r' as'command' atinit'source $ZDOTDIR/zlib/plugin_option/fzf.zsh'
zinit light junegunn/fzf

# BIND MULTIPLE WIDGETS USING FZF
zinit ice wait'0e' lucid multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zinit light junegunn/fzf

zinit light agkozak/zsh-z

zinit ice wait'1a' lucid  atload'bindkey "^d" dotbare-fedit' 
zinit light kazhala/dotbare

zinit ice as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX"
zinit light tj/git-extras

# FZF-TAB
zinit ice wait'1b' atload'source $ZDOTDIR/zlib/plugin_option/fzf-tab.zsh' atinit'_zpcompinit_custom; zpcdreplay' lucid
zinit light Aloxaf/fzf-tab

# Diff
zinit wait'1' lucid \
  from"gh-r" as"program" pick"delta*/delta" \
  light-mode for @dandavison/delta

zinit ice depth=1 atload'source $ZDOTDIR/zlib/plugin_option/zsh-vi-mode.zsh' lucid
zinit light jeffreytse/zsh-vi-mode

zinit ice wait'0b' lucid atload'source $ZDOTDIR/zlib/plugin_option/zsh-history-substring-search.zsh'
zinit light zsh-users/zsh-history-substring-search

zinit ice depth'1' lucid wait'0' atinit'_zpcompinit_custom; zpcdreplay'
zinit light zdharma-continuum/fast-syntax-highlighting

chpwd() exa --icons --color=always 
#source /usr/share/doc/pkgfile/command-not-found.zsh

print "[zshrc] ZSH took ${(M)$(( SECONDS * 1000 ))#*.?} ms"
