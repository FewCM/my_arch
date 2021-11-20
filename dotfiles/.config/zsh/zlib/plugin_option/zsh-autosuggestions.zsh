_zsh_autosuggest_setting() {
	# Remove forward-char widgets from ACCEPT
	ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${(@)ZSH_AUTOSUGGEST_ACCEPT_WIDGETS:#forward-char}")
	
	# Add forward-char widgets to PARTIAL_ACCEPT
	ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-char)

	#bindkey '^ ' autosuggest-accept
	#bindkey '^[[C' forward-word
	#bindkey "${terminfo[kcuf1]}" forward-word
	ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
	ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)"
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=orange"
}
