#!/usr/bin/env bash
function koca_isBackgrounded() { # Return true if process is backgrounded. Usage: $0
	# Thanks to http://is.gd/4h3fk0.
	case $(ps -o stat= -p $$) in
		*+*) return 1;;
		*) return 0;;
esac
}
