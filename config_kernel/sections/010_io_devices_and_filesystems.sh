#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring the available filesystems"

# Allow access to AHCI commands for SATA attached devices. This allows
# increased performance in both virtual and physical machines.
kernel_config --enable SATA_AHCI_PLATFORM

# Allow encrypted datamapper targets (and allow authenticated encryption using
# the integrity options)
kernel_config --enable DM_CRYPT
kernel_config --enable DM_INTEGRITY

# EXT4 isn't necessary for me
kernel_config --disable EXT4_FS

# XFS is my root filesystem of choice
kernel_config --enable XFS_FS
kernel_config --enable XFS_POSIX_ACL
kernel_config --enable XFS_ONLINE_SCRUB
kernel_config --enable XFS_ONLINE_REPAIR

# Quota support isn't needed for my systems
kernel_config --disable QUOTA

# Old school AutoFS support also isn't needed
kernel_config --disable AUTOFS4_FS
kernel_config --disable AUTOFS_FS

# Disable ISO filesystems
kernel_config --disable ISO9660_FS

# Tweaks to DOS/Win filesystems
kernel_config --disable MSDOS_FS
kernel_config --enable FAT_DEFAULT_UTF8

# Tweaks to the proc filesystem, both security and sanity reasons
kernel_config --disable PROC_KCORE

# TODO: This might be worth disabling if not necessary
#kernel_config --disable PROC_PAGE_MONITOR

# Random other filesystems
kernel_config --disable MISC_FILESYSTEMS

# Enable NFS client (but version 4.x only)
kernel_config --enable NFS_FS

kernel_config --disable NFS_V2
kernel_config --disable NFS_V3

kernel_config --enable NFS_V4
kernel_config --enable NFS_V4_1
kernel_config --enable NFS_V4_2
kernel_config --set-val NFS_V4_1_IMPLEMENTATION_ID_DOMAIN "kernel.org"
kernel_config --enable NFS_V4_SECURITY_LABEL

# By default I generally don't need the server but I do host NFS servers. It
# may be better to include this in the default kernel but for now I'm happy to
# leave this out.
#kernel_config --enable NFSD
#kernel_config --enable NFSD_V4

# This would be pretty neat to play around with at some point for some of my
# virtual machines but I don't need it for now.
kernel_config --disable ROOT_NFS

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
#kernel_config --enable BLK_DEV_RBD

# Samba / CIFS
#kernel_config --enable CIFS
#kernel_config --disable CIFS_ALLOW_INSECURE_LEGACY
#kernel_config --enable CIFS_UPCALL
#kernel_config --enable CIFS_XATTR
#kernel_config --enable CIFS_ACL
#kernel_config --enable CIFS_DFS_UPCALL

# Various block layer stuff I don't need
kernel_config --disable BLK_DEBUG_FS
kernel_config --disable BLK_DEV_BSG

# Get rid of various partition types we don't need
kernel_config --disable AMIGA_PARTITION
kernel_config --disable BSD_DISKLABEL
kernel_config --disable KARMA_PARTITION
kernel_config --disable MAC_PARTITION
kernel_config --disable MINIX_SUBPARTITION
kernel_config --disable OSF_PARTITION
kernel_config --disable SGI_PARTITION
kernel_config --disable SUN_PARTITION
kernel_config --disable SOLARIS_X86_PARTITION
kernel_config --disable UNIXWARE_DISKLABEL
