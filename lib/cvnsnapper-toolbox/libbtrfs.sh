# cvnsnapper-toolbox shell library libbtrfs.sh - btrfs helpers for cvnsnapper

is_subvol() {
	if ! [ "$#" -eq 1 ]
	then
		warn "Internal problem: is_subvol called with argument count $# instead of 1; returning false"
		return 1
	fi

	local CST_SUBVOL_MAYBE="$1"; shift

	[ -d "$CST_SUBVOL_MAYBE" ] || return 1

	[ "$(stat -c '%i' "$CST_SUBVOL_MAYBE")" = 256 ] || return 1

	return 0
}

subvol_get_uuid() {
	if ! [ "$#" -eq 1 ]
	then
		warn "Internal problem: subvol_get_uuid called with argument count $# instead of 1; returning false"
		return 1
	fi

	local CST_SUBVOL="$1"; shift

	local CST_UUID=
	CST_UUID="$(btrfs subvolume show "$CST_SUBVOL" | sed -n -e 's/^\s*UUID:\s*\([-0-9a-f]*\)$/\1/ip')" || return 1
	[ -n "$CST_UUID" ] || return 1
	[ "$CST_UUID" = "-" ] && return 1

	echo "$CST_UUID"
	return 0
}

subvol_get_received_uuid() {
	if ! [ "$#" -eq 1 ]
	then
		warn "Internal problem: subvol_get_received_uuid called with argument count $# instead of 1; returning false"
		return 1
	fi

	local CST_SUBVOL="$1"; shift

	local CST_RECEIVED_UUID=
	CST_RECEIVED_UUID="$(btrfs subvolume show "$CST_SUBVOL" | sed -n -e 's/^\s*Received UUID:\s*\([-0-9a-f]*\)$/\1/ip')"
	if [ -z "$CST_RECEIVED_UUID" ]
	then
		# Work-around for older btrfs tool versions,
		# which don't give out received UUID in "show".
		# So, use "list", instead. As we don't know
		# the path that is part of the btrfs,
		# match via subvolume UUID.

		local CST_UUID=
		CST_UUID="$(subvol_get_uuid "$CST_SUBVOL")" || return 1

		# -u: UUID, -R: received UUID
		CST_RECEIVED_UUID="$(btrfs subvolume list -u -R "$CST_SUBVOL" | sed -n -e "s/.* received_uuid \\([-0-9a-f]*\\) uuid $CST_UUID .*/\\1/ip")" || return 1
	fi

	[ -n "$CST_RECEIVED_UUID" ] || return 1
	#[ "$CST_RECEIVED_UUID" = "-" ] && return 1

	echo "$CST_RECEIVED_UUID"
	return 0
}
