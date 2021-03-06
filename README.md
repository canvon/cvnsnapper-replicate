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

## Install

This is all shell script (or Perl), so doesn't need compilation
before installation.

For installation, as root, run `make install`;
or, e.g., `make install DEST=/opt/cvnsnapper`.
This should install all the parts into destination's `lib/cvnsnapper-toolbox/`,
and the front-end script into `bin/`.

## Front-end script

As of commit 80ba152f274ac046e37f6f386d731f1fe9eed4cb (Mon Aug 17 15:36:54 2020 +0200)
"Switch from handful of scripts to a libdir + front-end script",
cvnsnapper is using a front-end script (in `bin/`) to invoke scripts
(in `lib/cvnsnapper-toolbox/`).

To invoke the `plain-backingstorage` script, invoke like this:

    # cvnsnapper plain-backingstorage show .

## Replication

`cvnsnapper replicate-send` is the main tool; from an existing
snapper `.snapshots` btrfs subvolume, it allows to turn the snapshots
into `btrfs send` output files for cold storage, or to orchestrate
`btrfs send | btrfs receive` pipelines (currently local-only, except for
experimental support for a bi-directional SSH pipeline, see below,)
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

Run something like this to get `btrfs send` stream files for cold storage:
(The `LAST_SNAPSHOT_NUMBER` is to not start with a full send, but
an incremental one, based on the snapshot with the given number.)

    # cd /srv/PATH/TO/SOURCE/.snapshots
    # cvnsnapper replicate-send /srv/PATH/TO/COLD/STORAGE [LAST_SNAPSHOT_NUMBER]

To replicate to a "live" btrfs on the same host (e.g., mounted backup disk),
use: (It should figure out the last snapshot on its own, but may be overridden
in case it doesn't work, or if some snapshots have been cleanup-deleted
since then.)

    # cd /srv/PATH/TO/SOURCE/.snapshots
    # cvnsnapper replicate-send --receive /mnt/PATH/ON/BACKUP/DISK [LAST_SNAPSHOT_NUMBER]

As of commit 59c1366 (Mon Aug 17 21:32:10 2020 +0200),
there is **EXPERIMENTAL** (read: alpha quality?) support for a receive script
running as root on another host, using a custom bi-directional message protocol
over SSH: `cvnsnapper replicate-receive`, although it should rather be set up
on the target host as an SSH forced command spelling out the actual script file
.., to try to avoid surprises. (Like, the front-end script getting fooled
to run scripts from a rogue directory, or the like...)

Please only use with SSH "restrict" option (near forced command `command="..."`
option in the `/root/.ssh/authorized_keys` file), if possible, and with care;
don't trust the script to protect your target host/server from any attacks
possible via crafted send streams, or to actually lock down the pubkey
to quasi-append only btrfs replication access as intended, yet (or ever?) ...

To actually use the `replicate-receive` back-end, on the source host, run:
(It should figure out the last snapshot via the bi-directional
message protocol.)

    # cd /srv/PATH/TO/SOURCE/.snapshots
    # cvnsnapper replicate-send --remote=HOST /srv/PATH/ON/REMOTE/HOST [LAST_SNAPSHOT_NUMBER]

Note that replication is idempotent (by accident), so should just succeed
without sending any snapshots if there are no newer ones.

## Import

In the case you've old, manual (`btrfs subvolume snapshot ...`) snapshots
lying around in the filesystem, this is intended to help you turn them
into proper snapper-based snapshots (organized by number and with attached
`info.xml`). Use `cvnsnapper import-byreplication`, which uses
`cvnsnapper import-name2infoxml` to convert from in-filesystem, in-snapshotname
description to snapper format.

## Plain filesystem operation

* `cvnsnapper plain-backingstorage` will successively determine
  where the storage a file system item is using comes from (e.g., btrfs), then,
  where that storage comes from (e.g., LVM), and so on. (cryptsetup/LUKS,
  partition, drive.)  Should walk through all the devices which are part of
  a multi-device btrfs. Even has a bit of ZFS support, though that is currently
  not well-tested.

*   `cvnsnapper plain-genmetadata` generates meta-data of a subvolume/snapshot,
    for later comparison, e.g., after replication. In theory, everything
    should be there, but I'm told that especially btrfs send|receive has some bugs,
    and better be safe than sorry!

    `cvnsnapper plain-statusmetadata` and `cvnsnapper plain-diffmetadata`
    are there to then make use of this generated meta-data, for snapper-like
    status (meta-data) and diff (file contents) output.

