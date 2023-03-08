dm-integrity: Linux in-kernel block level checksumming.

* Introduction:

The device-mapper is part of the kernel and provides a generic way to map physical block devices onto logical block
devices.  The architecture is conceptually very simple -- logical devices are described with a table, where each entry
in the table specifies a start sector, size, target name, and the target arguments.

Disk encryption, RAID, volume management (partitioning, thin provisioning, snapshotting) are some examples of user
visible functionality built using it.

The device-mapper integrity target[1] (aka dm-integrity) was added in 4.12, and emulates a block device that has additional
per-sector tags used for storing integrity information.  dm-integrity is used by dm-crypt to provide authenticated disk
encryption, or can be used standalone.  dm-integrity has lots of tuning parameters that affect performance.

* Setup:

  * Check run_test.sh, check DURATION and TEST_DEV.   

1. https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/device-mapper/dm-integrity.rst


