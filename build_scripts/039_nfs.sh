#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# If we used an NFS source for our portage during installation, set up the
# client and mount the directory automagically
if [ -z "${NFS_SOURCE}" ]; then
  exit 0
fi

echo 'net-fs/nfs-utils nfsdcld nfsv41' > /mnt/gentoo/etc/portage/package.use/nfs

chroot /mnt/gentoo emerge net-fs/nfs-utils

mkdir -p /mnt/gentoo/usr/src/kernel

# TODO: Once kerberos is setup I should set the sec mode to 'krb5p'
#
# When not on a build server, I may need to have this noexec, though I don't
# think that's necessary anymore. This should probably be read only as well for
# anything that isn't a build server.
cat << EOF >> /mnt/gentoo/etc/fstab

${NFS_SOURCE}:/cache          /var/cache       nfs4  rw,noatime,nodev,noexec,nosuid  0 0
${NFS_SOURCE}:/src_cache      /usr/src         nfs4  rw,noatime,nodev,noexec,nosuid  0 0
${NFS_SOURCE}:/kernel_config  /usr/src/kernel  nfs4  rw,noatime,nodev,noexec,nosuid  0 0
${NFS_SOURCE}:/pkg_repos      /var/db/repos    nfs4  rw,noatime,nodev,noexec,nosuid  0 0
EOF

# The following should be the build host export (ideally with sec=krb5p for
# integrity and encryption) /etc/exports
#
# /srv/build/stable  2604:a880:800:10::/48(ro,no_subtree_check,root_squash)  10.0.0.0/8(ro,no_subtree_check,root_squash)
