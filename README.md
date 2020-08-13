# cvnsnapper-toolbox

This is a collection of tools to operate on snapper-based btrfs snapshots,
and sometimes on btrfs subvolumes generally.  They have initially been written
in 2017, but some progress seems to be happening again in 2020.  The `cvn`
stands for `canvon`, the IRC nick name of the original author, *Fabian Pietsch*.
*snapper* is a program to manage filesystem-level snapshots, mostly on the
*btrfs* filesystem in the Linux kernel.

* <https://github.com/canvon/cvnsnapper-toolbox>: Hosted on GitHub.
* <https://www.canvon.de>: Original author's website.
* <http://snapper.io>: snapper website. (Hosted by GitHub, too, but there
  seems to be no valid SSL/TLS certificate configured as of 2020-08-13;
  therefore linking without https.)

## Replication

`cvnsnapper-replicate-send` is the main tool; from an existing
snapper `.snapshots` btrfs subvolume, it allows to turn the snapshots
into `btrfs send` output files for cold storage, or to orchestrate
`btrfs send | btrfs receive` pipelines (currently local-only)
for simple data replication in snapper form.

The former is the default, the latter gets activated by `--receive`.
In that case, `replicate-send` will automatically determine on which snapshot
we last left off, and start sending incrementally from the corresponding
source snapshot. As post-operation, it'll replace the destination main subvolume
and hang the `.snapshots` subvolume into there. The main subvolume has to be
set to read-only, before, and will be, after, as to not lose non-replicated
data on the destination main subvolume. (Perhaps this needs further checks?
Like, if there is some other subvolume in there which would be lost by the
deletion. Or whether it was in fact a snapshot of one of the replicated
snapper snapshots..?)

## Import

In the case you've old, manual (`btrfs subvolume snapshot ...`) snapshots
lying around in the filesystem, this is intended to help you turn them
into proper snapper-based snapshots (organized by number and with attached
`info.xml`). Use `cvnsnapper-import-byreplication`, which uses
`cvnsnapper-import-name2infoxml` to convert from in-filesystem, in-snapshotname
description to snapper format.

## Plain filesystem operation

* `cvnsnapper-plain-backingstorage` will successively determine
  where the storage a file system item is using comes from (e.g., btrfs), then,
  where that storage comes from (e.g., LVM), and so on. (cryptsetup/LUKS,
  partition, drive.)  Should walk through all the devices which are part of
  a multi-device btrfs. Even has a bit of ZFS support, though that is currently
  not well-tested.

*   `cvnsnapper-plain-genmetadata` generates meta-data of a subvolume/snapshot,
    for later comparison, e.g., after replication. In theory, everything
    should be there, but I'm told that especially btrfs send|receive has some bugs,
    and better be safe than sorry!

    `cvnsnapper-plain-statusmetadata` and `cvnsnapper-plain-diffmetadata`
    are there to then make use of this generated meta-data, for snapper-like
    status (meta-data) and diff (file contents) output.

