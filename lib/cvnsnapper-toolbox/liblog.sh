# cvnsnapper-toolbox shell library liblog.sh - logging for cvnsnapper

# Note: There's a copy of msg_{debug,info}() in cvnsnapper front-end script,
# as it's using those functions already while trying to work out the lib dir.
# After it found it, it'll source this file to get the canonical version,
# but if something should get changed here, please copy over the change
# to bin/cvnsnapper, too!

msg_info() {
	if [ -z "$CVNSNAPPER_TOOLBOX_VERBOSE" ] || ! [ "$CVNSNAPPER_TOOLBOX_VERBOSE" -ge 1 ]
	then
		return 0
	fi
	warn "Info: $*"
}

msg_debug() {
	if [ -z "$CVNSNAPPER_TOOLBOX_VERBOSE" ] || ! [ "$CVNSNAPPER_TOOLBOX_VERBOSE" -ge 2 ]
	then
		return 0
	fi
	warn "DEBUG: $*"
}
