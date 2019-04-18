#!/bin/bash

. ./_error_handling.sh
. ./_config.sh
. ./_common_functions.sh

log "Configuring the available filesystems"

# EXT4 isn't necessary for me
kernel_config --disable EXT4_FS
kernel_config --disable EXT4_USE_FOR_EXT2
kernel_config --disable EXT4_FS_POSIX_ACL
kernel_config --disable EXT4_FS_SECURITY
kernel_config --undefine JBD2

# XFS is my root filesystem of choice
kernel_config --enable XFS_FS
kernel_config --enable XFS_POSIX_ACL
kernel_config --enable XFS_ONLINE_SCRUB
kernel_config --enable XFS_ONLINE_REPAIR

# Quota support isn't needed for my systems
kernel_config --disable QUOTA
kernel_config --disable QUOTACTL
kernel_config --disable QUOTA_NETLINK_INTERFACE
kernel_config --undefine QFMT_V2
kernel_config --undefine QUOTACTL_COMPAT
kernel_config --undefine QUOTA_TREE

# Old school AutoFS support also isn't needed
kernel_config --disable AUTOFS4_FS
kernel_config --disable AUTOFS_FS

# Disable ISO filesystems
kernel_config --disable ISO9660_FS
kernel_config --disable JOLIET
kernel_config --disable ZISOFS

# Tweaks to DOS/Win filesystems
kernel_config --disable MSDOS_FS
kernel_config --enable FAT_DEFAULT_UTF8

# Tweaks to the proc filesystem, both security and sanity reasons
kernel_config --disable PROC_KCORE
kernel_config --undefine ARCH_PROC_KCORE_TEXT
kernel_config --undefine FS_MBCACHE

# TODO: This might be worth disabling if not necessary
#kernel_config --disable PROC_PAGE_MONITOR

# Random other filesystems
kernel_config --disable MISC_FILESYSTEMS

# Enable NFS client (but version 4.x only)
kernel_config --enable NFS_FS

kernel_config --disable NFS_V2
kernel_config --disable NFS_V3
kernel_config --disable NFS_V3_ACL
kernel_config --undefine LOCKD_V4
kernel_config --undefine NFS_ACL_SUPPORT

kernel_config --enable NFS_V4
kernel_config --enable NFS_V4_1
kernel_config --enable NFS_V4_2
kernel_config --set-val NFS_V4_1_IMPLEMENTATION_ID_DOMAIN "kernel.org"
kernel_config --enable NFS_V4_SECURITY_LABEL
kernel_config --enable PNFS_BLOCK
kernel_config --enable PNFS_FILE_LAYOUT
kernel_config --enable SUNRPC_BACKCHANNEL

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

# Samba / CIFS
#kernel_config --enable CIFS
#kernel_config --disable CIFS_ALLOW_INSECURE_LEGACY
#kernel_config --enable CIFS_UPCALL
#kernel_config --enable CIFS_XATTR
#kernel_config --enable CIFS_ACL
#kernel_config --enable CIFS_DFS_UPCALL
