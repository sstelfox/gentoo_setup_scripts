#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

if [ -n "${BIN_HOST:-}" ]; then
  binpkgfeature=" getbinpkg"
fi

cat << EOF > /mnt/gentoo/etc/portage/make.conf
CFLAGS="-O2 -pipe"
CXXFLAGS="\${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"

EMERGE_DEFAULT_OPTS="--jobs $(($(nproc) + 1)) --load-average $(nproc) --binpkg-respect-use=y"
FEATURES="buildpkg cgroup getbinpkg ipc-sandbox network-sandbox${binpkgfeature:-}"
USE="audit caps cgroups kerberos python -perl -systemd -tcpd"

GRUB_PLATFORMS="efi-64 pc"
POLICY_TYPES="strict"

L10N="en"
LINGUAS="en"
EOF

if [ -n "${GENTOO_MIRRORS:-}" ]; then
  echo -e "\nGENTOO_MIRRORS=\"${GENTOO_MIRRORS}\"" >> /mnt/gentoo/etc/portage/make.conf
elif [ "${LOCAL}" != "yes" ]; then
  mirrorselect -o -s 3 -q -D -H -R 'North America' 2> /dev/null >> /mnt/gentoo/etc/portage/make.conf
fi

if [ -n "${BIN_HOST:-}" ]; then
  echo "PORTAGE_BINHOST=\"${BIN_HOST}\"" >> /mnt/gentoo/etc/portage/make.conf
fi

mkdir -p /mnt/gentoo/etc/portage/package.use
echo 'app-shells/bash -net' > /mnt/gentoo/etc/portage/package.use/bash
