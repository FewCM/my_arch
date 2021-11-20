#!/usr/bin/env zsh
#skip_global_compinit=1

# Execute code in the background to not affect the current session
{
    # Compile zcompdump, if modified, to increase startup speed.
    zcompdump="${ZDOTDIR}/.zcompdump"
    if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
        zcompile "$zcompdump"
    fi
} &!
