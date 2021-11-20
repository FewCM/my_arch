#!/bin/zsh

function ll() { # A superb ls
	ls -AhlXF --color=auto --time-style="+[34m[[32m%g-%m-%d [35m%k:%M[33m][m" $@
	[[ "$*" == "$1" ]] && echo "  \033[1;96m--[\033[1;34m Dir: \033[36m`ls -Al $@ | grep '^drw' | wc -l`\033[1;32m |\033[1;33m File: \033[32m`ls -Al $@ | grep -v '^drw' | grep -v total | wc -l` ]-- \033[1;37m"
}

function ca() {
	if [ "$#" -gt 0 ]; then
		cal "$@"
	else
		cal | sed -e "s/$(date +%e)/$(printf '\e[1;32m')$(date +%e)$(printf '\e[00m')/"
	fi
}

function ytdl() {
	for id in "$@"; do
		youtube-dl -ic -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' --write-srt --sub-lang en --add-metadata "https://youtube.com/watch?v=$id"
	done
}

function fp() {
printf "$(pacman --color always "${@:--Ss}" \
	| sed 'N;s/\n//' \
	| fzf -m --ansi --preview 'pacman -Si {1}' \
	| sed 's/ .*//')\n"
}

function fpacin() {
	sudo pacman -S $(fp)
}

function escape_color() {
  for code in {0..255}
    do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m"
  done
}

function 16_escape_color() {
  for code in {30..37}; do \
	echo -en "\e[${code}m"'\\e['"$code"'m'"\e[0m"; \
	echo -en "  \e[$code;1m"'\\e['"$code"';1m'"\e[0m"; \
	echo -en "  \e[$code;3m"'\\e['"$code"';3m'"\e[0m"; \
	echo -en "  \e[$code;4m"'\\e['"$code"';4m'"\e[0m"; \
	echo -e "  \e[$((code+60))m"'\\e['"$((code+60))"'m'"\e[0m"; \
done
}

#
# Functions
#
# Runs bindkey but for all of the keymaps. Running it with no arguments will
# print out the mappings for all of the keymaps.
function bindkey-all {
  local keymap=''
  for keymap in $(bindkey -l); do
    [[ "$#" -eq 0 ]] && printf "#### %s\n" "${keymap}" 1>&2
    bindkey -M "${keymap}" "$@"
  done
}


#####################
# FANCY-CTRL-Z      #
#####################
function fg-fzf() {
	job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job
}

function fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		BUFFER=" fg-fzf"
		zle accept-line -w
	else
		zle push-input -w
		zle clear-screen -w
	fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

function pacsize() {
	pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h
}


# copy directory and cd to it
function cpcd() {
  if [ -d "$2" ];then
    cp "$1" "$2" && (cd "$2" || exit)
  else
    cp "$1" "$2"
  fi
}

# move directory and cd to it
function mvcd() {
  if [ -d "$2" ];then
    mv "$1" "$2" && (cd "$2" || exit)
  else
    mv "$1" "$2"
  fi
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	# shellcheck disable=SC2199
	if [[ -n "$@" ]]; then
		du $arg -- "$@"
	else
		du $arg -- .[^.]* *
	fi
}


function list() {
  fzf -m --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || bat --style=numbers --color=always {}' | xargs ls -lha
}

function disappointed() { 
	echo -n " ಠ_ಠ " |tee /dev/tty| xclip -selection clipboard; 
}

function flip() { 
	echo -n "（╯°□°）╯ ┻━┻" |tee /dev/tty| xclip -selection clipboard; 
}

function shrug() { 
	echo -n "¯\_(ツ)_/¯" |tee /dev/tty| xclip -selection clipboard; 
}

function matrix() { 
	echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4;        letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}' 
}

function fman() {
    man -k . | fzf -q "$1" --prompt='man> '  --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}

function in() {
    yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}'| xargs -ro yay -S
}

function re() {
    yay -Qq | fzf -q "$1" -m --preview 'yay -Qil {1}' | xargs -ro yay -Rnsc
}

function promptspeed() {
    for i in $(seq 1 10); do /usr/bin/time zsh -i -c exit; done
}

#runs which, and prints the contents of the function/script
function which-cat() {
	local COMMAND_OUTPUT USER_INPUT
	USER_INPUT="${1:?Must provide a command to lookup}"
	if COMMAND_OUTPUT="$(which "${USER_INPUT}")"; then
		# if the file is readable
		if [[ -r "${COMMAND_OUTPUT}" ]]; then
			if iconv --from-code="utf-8" --to-code="utf-8" "${COMMAND_OUTPUT}" >/dev/null 2>&1; then
				command cat "${COMMAND_OUTPUT}"
			else
				file "${COMMAND_OUTPUT}"
			fi
		else
			# error finding command, or its an alias/function
			printf '%s\n' "${COMMAND_OUTPUT}"
		fi
	else
		printf '%s\n' "${COMMAND_OUTPUT}" >&2
	fi
}

function zsh_stats() {
  fc -l 1 \
    | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' \
    | grep -v "./" | sort -nr | head -20 | column -c3 -s " " -t | nl
}


function sfont() {
	fc-cache
	fc-list		|
	cut -f2,3 -d:	|
	grep -i "$1" |
	sort
}

function blocks() {
	echo; echo; for i in 0 1 2 3 4 5 6 7; do
		printf '\033[10%bm	 \033[s\033[1A\033[3D\033[4%bm	 \033[u' "$i" "$i"
	done; printf '\n\033[0m'
}

function 256col() {
	for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

function xrescol() {
	read -r -d '' -A colors \
			< <( xrdb -query | sed -n 's/st.color\([0-9]\)/\1/p' | sort -nu | cut -f2)
	printf '\e[1;37m\nBlack		Red	Green	Yellow	Blue	Magenta	Cyan	White\n───────────────────────────────────────────────────────────────────────────────────────\e[0m\n'
	for color in {0..7}; do printf "\e[$((30+color))m █ %s \e[0m" "${colors[color+1]}"; done
	printf '\n'
	for color in {8..15}; do printf "\e[1;$((22+color))m █ %s \e[0m" "${colors[color+1]}"; done
	printf '\n'
}
