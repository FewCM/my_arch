define-command toggle-highlighter -params 2.. -docstring 'toggle-highlighter <path>/[name] <type> [type-params…]' %{
    try %{
        # Forward arguments to add-highlighter
        add-highlighter %arg{@}

        # Display message
        echo -markup "{green}add-highlighter %arg{@}{Default}"
    } catch %{
        # Something went wrong; most likely duplicate ID.
        #
        # Signature:
        # add-highlighter <path>/[name] <type> [type-params…]
        #
        # If [name] is empty, it will be auto-generated.
        # https://github.com/mawww/kakoune/blob/master/src/commands.cc
        evaluate-commands %sh{
            auto_name() {
                printf '%s' "$*" | sed '
                    s_/_<slash>_g
                    s/ /_/g
                '
            }

            # Get the highlighter path name
            path=$1
            case "$path" in
                *'/')
                    auto_name=$(shift; auto_name "$@")
                    path=${path}${auto_name}
                    ;;
            esac

            # Execute the command
            printf 'remove-highlighter "%s"\n' "$path"
            printf 'echo -markup "{red}remove-highlighter %s{Default}"\n' "$path"
        }
    }
}
