#!/bin/zsh

skip_global_compinit=1

umask 022
unsetopt GLOBAL_RCS
setopt noglobalrcs
# 10ms for key sequences (Decrease key input delay)
# https://www.johnhawthorn.com/2012/09/vi-escape-delays/
export KEYTIMEOUT=1

# LANGUAGE must be set by en_US
export LANGUAGE="en_US.UTF-8"
export LANG="${LANGUAGE}"
GPG_TTY=$(tty)
export GPG_TTY
export XCURSOR_THEME=Bibata-Original-Amber

# XDG based directories {{{1
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_DATA_DIRS="$XDG_DATA_HOME:/usr/share:/usr/local/share"

export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_VIDEOS_DIR="$HOME/Videos"

export USERXSESSION="$XDG_CACHE_HOME/X11/xsession"
export USERXSESSIONRC="$XDG_CACHE_HOME/X11/xsessionrc"
export ALTUSERXSESSION="$XDG_CACHE_HOME/X11/Xsession"
export ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors"

# aurutils
#export AUR_REPO=my_repo
#export AUR_DBROOT="/home/fewcm/git/my_repo/x86_64"
export AUR_REPO=fewcm-local
export AUR_DBROOT="/run/media/Storage"
export AUR_QUERY_PARALLEL=1
export AUR_QUERY_PARALLEL_MAX=10

export WGETRC="$XDG_CONFIG_HOME/wgetrc"

#XDG_Base_Directory
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc

export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_PATH="${HOME}/.npm-packages:/lib/node_modules:$NODE_PATH"
export NPM_PACKAGES="${HOME}/.npm-packages"
export NPM_PACKAGES_DIRECTORY=$NPM_PACKAGES
export PATH="${HOME}/.npm-packages/bin:$PATH"


# General System Conf{{{2
export COLORTERM=truecolor
#export TERM="xterm-256color"

export EDITOR=micro
export VISUAL=micro
export SUDO_EDITOR=micro # for systemctl
export SYSTEMD_EDITOR=$EDITOR # for systemctl
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
#export LESS="-R " # colorize output
export LESS="-iRX --mouse --wheel-lines 2 --status-column --LONG-PROMPT --quit-on-intr --no-histdups"
export LESSHISTFILE=-
export LESSOPEN='|~/.local/bin/lessfilter %s'
# }}}

# LESS (and man) colors{{{2
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"     
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"   
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"     
export LESS_TERMCAP_so="$(printf '%b' '[01;34;40m')" 
export LESS_TERMCAP_me="$(printf '%b' '[0m')"        
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"        
export LESS_TERMCAP_se="$(printf '%b' '[0m')" 
# }}}

export EXA_ICON_SPACING=1
## ==== extended EXA_COLORS: ====
# no=00:fi=00:di=38;5;111:ln=38;5;81:pi=38;5;43:bd=38;5;212:\
# cd=38;5;225:or=30;48;5;202:ow=38;5;75:so=38;5;177:su=36;48;5;63:ex=38;5;156:\
# mi=38;5;115:*.exe=38;5;156:*.bat=38;5;156:*.tar=38;5;204:*.tgz=38;5;205:\
# *.tbz2=38;5;205:*.zip=38;5;206:*.7z=38;5;206:*.gz=38;5;205:*.bz2=38;5;205:\
# *.rar=38;5;205:*.rpm=38;5;173:*.deb=38;5;173:*.dmg=38;5;173:\
# *.jpg=38;5;141:*.jpeg=38;5;147:*.png=38;5;147:\
# *.mpg=38;5;151:*.mpeg=38;5;151:*.avi=38;5;151:*.mov=38;5;216:*.wmv=38;5;216:\
# *.mp4=38;5;217:*.mkv=38;5;216:*.flac=38;5;223:*.mp3=38;5;218:*.wav=38;5;213:\
# *akefile=38;5;176:*.pdf=38;5;253:*.ods=38;5;224:*.odt=38;5;146:\
# *.doc=38;5;224:*.xls=38;5;146:*.docx=38;5;224:*.xlsx=38;5;146:\
# *.epub=38;5;152:*.mobi=38;5;105:*.m4b=38;5;222:*.conf=38;5;121:\
# *.md=38;5;224:*.markdown=38;5;224:*README=38;5;224:*.ico=38;5;140:\
# *.iso=38;5;205"

# ZSH variables: {{{1
export ZDOTDIR="$HOME/.config/zsh"

# History file configuration
export HISTFILE="$HOME/.config/zsh/history"
export HISTSIZE=68400
export SAVEHIST=$((HISTSIZE/2))
export HISTORY_IGNORE="(ls|pwd|zsh|exit)"
# Corrections
export CORRECT_IGNORE_FILE='.*'

# Language/Programs Specifics {{{1
#export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"
export QT_QPA_PLATFORMTHEME="qt5ct"
#export QT_QPA_PLATFORMTHEME=gtk2

export ZSHZ_CMD="z"
export ZSHZ_DATA="$ZDOTDIR/.z"
export ZSHZ_ECHO=1

export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass
export PASSWORD_STORE_ENABLE_EXTENSIONS=true
export PASSWORD_STORE_EXTENSIONS_DIR="$XDG_DATA_HOME"/pass/extensions
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

MICRO_TRUECOLOR=1
export RANGER_LOAD_DEFAULT_RC=FALSE
export CM_LAUNCHER=rofi

# dotbare {{{2
export DOTBARE_DIR="$HOME/.dotfiles"
export DOTBARE_TREE="$HOME"
export DOTBARE_BACKUP="${XDG_DATA_HOME:-$HOME/.local/share}/dotbare"
export DOTBARE_FZF_DEFAULT_OPTS="--preview-window=right:65%"
export DOTBARE_KEY="
  --bind=alt-a:toggle-all
  --bind=alt-w:jump
  --bind=alt-0:top
  --bind=alt-s:toggle-sort
  --bind=alt-t:toggle-preview
"
export DOTBARE_PREVIEW="cat -n {}"
export DOTBARE_DIFF_PAGER="delta --diff-so-fancy --line-numbers"
# }}}

# This is the list for lf icons:
export LF_ICONS="\
tw=:\
st=:\
ow=:\
dt=:\
di=:\
fi=:\
ln=:\
or=:\
ex=:\
*.c=:\
*.cc=:\
*.clj=:\
*.coffee=:\
*.cpp=:\
*.css=:\
*.d=:\
*.dart=:\
*.erl=:\
*.exs=:\
*.fs=:\
*.go=:\
*.h=:\
*.hh=:\
*.hpp=:\
*.hs=:\
*.html=:\
*.java=:\
*.jl=:\
*.js=:\
*.json=:\
*.lua=:\
*.md=:\
*.php=:\
*.pl=:\
*.pro=:\
*.py=:\
*.rb=:\
*.rs=:\
*.scala=:\
*.ts=:\
*.vim=:\
*.cmd=:\
*.ps1=:\
*.sh=:\
*.bash=:\
*.zsh=:\
*.fish=:\
*.tar=:\
*.tgz=:\
*.arc=:\
*.arj=:\
*.taz=:\
*.lha=:\
*.lz4=:\
*.lzh=:\
*.lzma=:\
*.tlz=:\
*.txz=:\
*.tzo=:\
*.t7z=:\
*.zip=:\
*.z=:\
*.dz=:\
*.gz=:\
*.lrz=:\
*.lz=:\
*.lzo=:\
*.xz=:\
*.zst=:\
*.tzst=:\
*.bz2=:\
*.bz=:\
*.tbz=:\
*.tbz2=:\
*.tz=:\
*.deb=:\
*.rpm=:\
*.jar=:\
*.war=:\
*.ear=:\
*.sar=:\
*.rar=:\
*.alz=:\
*.ace=:\
*.zoo=:\
*.cpio=:\
*.7z=:\
*.rz=:\
*.cab=:\
*.wim=:\
*.swm=:\
*.dwm=:\
*.esd=:\
*.jpg=:\
*.jpeg=:\
*.mjpg=:\
*.mjpeg=:\
*.gif=:\
*.bmp=:\
*.pbm=:\
*.pgm=:\
*.ppm=:\
*.tga=:\
*.xbm=:\
*.xpm=:\
*.tif=:\
*.tiff=:\
*.png=:\
*.svg=:\
*.svgz=:\
*.mng=:\
*.pcx=:\
*.mov=:\
*.mpg=:\
*.mpeg=:\
*.m2v=:\
*.mkv=:\
*.webm=:\
*.ogm=:\
*.mp4=:\
*.m4v=:\
*.mp4v=:\
*.vob=:\
*.qt=:\
*.nuv=:\
*.wmv=:\
*.asf=:\
*.rm=:\
*.rmvb=:\
*.flc=:\
*.avi=:\
*.fli=:\
*.flv=:\
*.gl=:\
*.dl=:\
*.xcf=:\
*.xwd=:\
*.yuv=:\
*.cgm=:\
*.emf=:\
*.ogv=:\
*.ogx=:\
*.aac=:\
*.au=:\
*.flac=:\
*.m4a=:\
*.mid=:\
*.midi=:\
*.mka=:\
*.mp3=:\
*.mpc=:\
*.ogg=:\
*.ra=:\
*.wav=:\
*.oga=:\
*.opus=:\
*.spx=:\
*.xspf=:\
*.pdf=:\
*.nix=:\
"

export PATH="$PATH:${$(find $HOME/.local/bin $HOME/.config/rofi/dwm/bin $HOME/.config/polybar/dwm/bin -type d -printf %p:)%%:}"
typeset -U path PATH sudo_path cdpath fpath

# https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshenv
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

if [ "$TERM" = "linux" ]; then
    _SEDCMD='s/.*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
    for i in $(sed -n "$_SEDCMD" $HOME/.config/X11/dwm/colors | awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
        echo -en "$i"
    done
    clear
fi


