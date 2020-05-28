#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

if [ -n "${BIN_HOST:-}" ]; then
  binpkgfeature="getbinpkg"
fi

# Using these options will make the initial system builds go faster, but when
# used as a base image may cause issues as they don't get continuously updated
# with the actual system's CPU information
EMERGE_DEFAULT_OPTS="--jobs $(($(nproc) + 1)) --load-average $(nproc)"

cat << EOF > /mnt/gentoo/etc/portage/make.conf
CFLAGS="-O2 -pipe"
CXXFLAGS="\${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"

EMERGE_DEFAULT_OPTS="--binpkg-respect-use=y"
FEATURES="buildpkg cgroup ipc-sandbox network-sandbox ${binpkgfeature:-}"
USE="audit caps cgroups hardened ipv6 kerberos python -perl -systemd -tcpd"

GRUB_PLATFORMS="efi-64 pc"
POLICY_TYPES="strict"

L10N="en"
LINGUAS="en"
EOF

mkdir -p /mnt/gentoo/etc/portage/package.use
cat << EOF > /mnt/gentoo/etc/portage/package.use/restrict_unstable_python_upgrade
*/* PYTHON_TARGETS: -python3_7 python3_6
*/* PYTHON_SINGLE_TARGET: -* python_3_6
EOF

if [ -n "${GENTOO_MIRRORS:-}" ]; then
  echo -e "\nGENTOO_MIRRORS=\"${GENTOO_MIRRORS}\"" >> /mnt/gentoo/etc/portage/make.conf
elif [ "${LOCAL}" != "yes" ]; then
  # Only attempt to find the fastest Gentoo mirror if the utility is available
  if which mirrorselect &> /dev/null; then
    mirrorselect -o -s 3 -q -D -H -R 'North America' 2> /dev/null >> /mnt/gentoo/etc/portage/make.conf
  fi
fi

if [ -n "${BIN_HOST:-}" ]; then
  echo "PORTAGE_BINHOST=\"${BIN_HOST}\"" >> /mnt/gentoo/etc/portage/make.conf
fi

mkdir -p /mnt/gentoo/etc/portage/package.use
echo 'app-shells/bash -net' > /mnt/gentoo/etc/portage/package.use/bash
