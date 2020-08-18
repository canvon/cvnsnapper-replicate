# cvnsnapper-toolbox shell library liblog.sh - logging for cvnsnapper

# Note: There's a copy of msg_{debug,info}() in cvnsnapper front-end script,
# as it's using those functions already while trying to work out the lib dir.
# After it found it, it'll source this file to get the canonical version,
# but if something should get changed here, please copy over the change
# to bin/cvnsnapper, too!

is_info()  { [ "${CVNSNAPPER_TOOLBOX_VERBOSE:-0}" -ge 1 ]; }
is_debug() { [ "${CVNSNAPPER_TOOLBOX_VERBOSE:-0}" -ge 2 ]; }

msg_info() {
	is_info || return 0
	warn "Info: $*"
}

msg_debug() {
	is_debug || return 0
	warn "DEBUG: $*"
}
