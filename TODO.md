# TODO

TODO for cvnsnapper-replicate project.


## cvnsnapper-replicate-receive

  * Add, implement.


## cvnsnapper-replicate-statusmetadata

  * Allow mapping of difference field names to flag chars
    like in "snapper status".

  * Add profiles for ignoring differences based on field names.
    (e.g., snapshot-to-other-snapshot, or source host to destination host.)

  * Read in and diff checksums as well, to detect file content changes
    with same size/inode/mtime. (On the source host, they can be detected
    via a changed ctime, but on the destination host, all ctimes will differ
    anyway.)

