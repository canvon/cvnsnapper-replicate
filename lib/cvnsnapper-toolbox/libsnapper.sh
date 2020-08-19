# For VIM syntax highlighting: This is bash
#
# cvnsnapper-toolbox shell library libsnapper.sh - snapper helpers for cvnsnapper

# (For is_snapper_snapshot(), see libbtrfs.sh,
# as its implementation fits better to there.)

parse_snapper_info() {
	if ! [ "$#" -eq 0 ]
	then
		warn "Internal problem: parse_snapper_info input/output go via variables, but called with argument count $# instead of 0; returning false"
		return 1
	fi

	if ! [ -n "$SNAPSHOT_INFO" ]
	then
		warn "Internal problem: parse_snapper_info called without SNAPSHOT_INFO being set; returning false"
		return 1
	fi

	if ! [ -f "$SNAPSHOT_INFO" ]
	then
		warn "Missing snapper snapshot info.xml at \"$SNAPSHOT_INFO\""
		return 1
	fi

	local CST_FAIL=0
	SNAPSHOT_NUM=$(sed -n -e 's#^.*<num>\([^<]*\)</num>.*#\1#p' <"$SNAPSHOT_INFO") || { CST_FAIL=1; warn "While extracting snapper snapshot info.xml \"$SNAPSHOT_INFO\" num: sed failed"; }
	SNAPSHOT_DATE=$(sed -n -e 's#^.*<date>\([^<]*\)</date>.*#\1#p' <"$SNAPSHOT_INFO") || { CST_FAIL=1; warn "While extracting snapper snapshot info.xml \"$SNAPSHOT_INFO\" date: sed failed"; }
	SNAPSHOT_TYPE=$(sed -n -e 's#^.*<type>\([^<]*\)</type>.*#\1#p' <"$SNAPSHOT_INFO") || { CST_FAIL=1; warn "While extracting snapper snapshot info.xml \"$SNAPSHOT_INFO\" type: sed failed"; }
	SNAPSHOT_UID=$(sed -n -e 's#^.*<uid>\([^<]*\)</uid>.*#\1#p' <"$SNAPSHOT_INFO") || { CST_FAIL=1; warn "While extracting snapper snapshot info.xml \"$SNAPSHOT_INFO\" uid: sed failed"; }
	SNAPSHOT_DESCRIPTION=$(sed -n -e 's#^.*<description>\([^<]*\)</description>.*#\1#p' <"$SNAPSHOT_INFO") || { CST_FAIL=1; warn "While extracting snapper snapshot info.xml \"$SNAPSHOT_INFO\" description: sed failed"; }
	SNAPSHOT_CLEANUP=$(sed -n -e 's#^.*<cleanup>\([^<]*\)</cleanup>.*#\1#p' <"$SNAPSHOT_INFO") || { CST_FAIL=1; warn "While extracting snapper snapshot info.xml \"$SNAPSHOT_INFO\" cleanup policy: sed failed"; }
	[ "$CST_FAIL" -eq 0 ] || return 2

	return 0
}
