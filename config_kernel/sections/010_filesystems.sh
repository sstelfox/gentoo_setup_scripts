#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring the available filesystems"

# Recommended by the Gentoo Handbook: "Also select Maintain a devtmpfs file
# system to mount at /dev so that critical device files are already available
# early in the boot process (CONFIG_DEVTMPFS and DEVTMPFS_MOUNT)":
kernel_config --enable DEVTMPFS
kernel_config --enable DEVTMPFS_MOUNT

kernel_config --enable PROC_FS
kernel_config --enable SYSFS

kernel_config --enable XFS_FS
kernel_config --enable XFS_POSIX_ACL
kernel_config --enable XFS_ONLINE_SCRUB
kernel_config --enable XFS_ONLINE_REPAIR

# FAT32 is required for EFI
kernel_config --enable VFAT_FS
kernel_config --enable FAT_DEFAULT_UTF8

# Enable NFS server and client
kernel_config --enable NETWORK_FILESYSTEMS
kernel_config --enable NFS_FS
kernel_config --disable NFS_V2
kernel_config --disable NFS_V3
kernel_config --enable NFS_V3_ACL
kernel_config --enable NFS_V4
kernel_config --enable NFS_V4_1
kernel_config --enable NFS_V4_2
kernel_config --enable NFSD
kernel_config --enable NFSD_V3
kernel_config --enable NFSD_V3_ACL
kernel_config --enable NFSD_V4

# File locking is required for NFS filesystems
kernel_config --enable FILE_LOCKING

# TODO: The following

# In the future I may want to use this to export virtual machine images over
# NFS...
#kernel_config --enable EXPORTFS_BLOCK_OPS
#kernel_config --enable NFSD_BLOCKLAYOUT
#kernel_config --enable NFSD_SCSILAYOUT
#kernel_config --enable NFSD_FLEXFILELAYOUT

# Eventually I will play with Ceph, I'll want to enable this:
#kernel_config --enable CEPH_FS
#kernel_config --enable CEPH_FS_POSIX_ACL
#kernel_config --enable CEPH_LIB

# Samba / CIFS
#kernel_config --enable CIFS
#kernel_config --disable CIFS_ALLOW_INSECURE_LEGACY
#kernel_config --enable CIFS_UPCALL
#kernel_config --enable CIFS_XATTR
#kernel_config --enable CIFS_ACL
#kernel_config --enable CIFS_DFS_UPCALL

# TODO: This might be worth disabling if not necessary
#kernel_config --disable PROC_PAGE_MONITOR

# Allow tmpfs to have security attributes on it
kernel_config --enable TMPFS_POSIX_ACL
