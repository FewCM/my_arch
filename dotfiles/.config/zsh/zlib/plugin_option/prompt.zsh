SPACESHIP_PROMPT_ORDER=(
	#ssh                # SSH connection indicator
	vi_mode
	user               # Username section
	#host               # Hostname section
	dir                # Current directory section
	git
	line_sep           # Line break
	char               # Prompt character, with vi-mode indicator integrated
)

SPACESHIP_RPROMPT_ORDER=(
	exit_code # Exit code section
	exec_time # Execution time
	jobs      # Background jobs indicator
	time      # Time stampts section
)
	
	SPACESHIP_CHAR_COLOR_SUCCESS=003
	SPACESHIP_CHAR_SYMBOL='λ '
	SPACESHIP_CHAR_SYMBOL_ROOT=' λ ' 

	SPACESHIP_VI_MODE_INSERT='>' 
	SPACESHIP_VI_MODE_NORMAL='<'
	SPACESHIP_VI_MODE_COLOR=red

	SPACESHIP_TIME_SHOW=true
	SPACESHIP_TIME_FORMAT='󱕅 %t'
	#SPACESHIP_TIME_12HR=true

