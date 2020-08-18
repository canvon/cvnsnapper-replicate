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
