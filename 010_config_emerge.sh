#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

cat << EOF > /mnt/gentoo/etc/portage/make.conf
CFLAGS="-O2 -pipe"
CXXFLAGS="\${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"

EMERGE_DEFAULT_OPTS="--jobs $(($(nproc) + 1)) --load-average $(nproc)"
FEATURES="cgroup ipc-sandbox network-sandbox"
USE="audit caps cgroups mmx kerberos python sctp sse sse2 -perl -systemd -tcpd"

GRUB_PLATFORMS="efi-64 pc"
POLICY_TYPES="strict"

L10N="en"
LINGUAS="en"

EOF

if [ -z "${GENTOO_MIRRORS:-}" ]; then
  echo -e "\nGENTOO_MIRRORS=\"${GENTOO_MIRRORS}\"" >> /mnt/gentoo/etc/portage/make.conf
elif [ "${LOCAL}" != "yes" ]; then
  mirrorselect -o -s 3 -q -D -H -R 'North America' 2> /dev/null >> /mnt/gentoo/etc/portage/make.conf
fi

mkdir -p /mnt/gentoo/etc/portage/package.use
echo 'app-shells/bash -net' > /mnt/gentoo/etc/portage/package.use/bash
