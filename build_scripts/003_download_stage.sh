#!/bin/bash

# TODO: Add function helper for executing in a chroot and for writing to
# targeted base paths.

. ./_config.sh
. ./_error_handling.sh

# In the event we don't have a specific mirror for our general stage download
# fallback on a random one I chose that was a good mirrorselect once upon a
# time.
STAGE_MIRROR="${GENTOO_MIRRORS:-http://gentoo.mirrors.easynews.com/linux/gentoo/}"

if [ "${LOCAL}" != "yes" ]; then
  TARGET_FILES=$(curl -s "${STAGE_MIRROR}/releases/amd64/autobuilds/current-stage4-amd64-hardened+minimal-nomultilib/" | grep -oE 'stage4-amd64-hardened\+minimal-nomultilib-[0-9TZ]+\.tar\.xz(\.DIGESTS\.asc)?')
  for FILE in ${TARGET_FILES}; do
    curl -s -C - -o /mnt/gentoo/${FILE} ${STAGE_MIRROR}/releases/amd64/autobuilds/current-stage4-amd64-hardened+minimal-nomultilib/${FILE}
  done

  rm -rf /root/.gnupg
  mkdir -p /root/.gnupg
  chmod 0700 /root/.gnupg

  cat << 'EOF' > /root/.gnupg/gpg.conf
require-cross-certification
keyserver keys.gnupg.net
EOF
  chmod 0600 /root/.gnupg/gpg.conf

  # Gentoo Release Signing Key, Kind of disappoint this isn't shipped on the ISO
  # which also has to be cryptographically checked. We have to receive this to
  # continue...
  if [ -f "${BASE_DIRECTORY}/gentoo_signing_key.gpg" ]; then
    gpg2 --import ${BASE_DIRECTORY}/gentoo_signing_key.gpg
  else
    gpg2 --recv-keys 0xBB572E0E2D182910
  fi

  # The script will automatically abort if this check fails
  gpg2 --verify /mnt/gentoo/*.tar.xz.DIGESTS.asc

  SHA512_DGST=$(openssl dgst -r -sha512 /mnt/gentoo/*.tar.xz | awk '{ print $1 }')
  GOOD_SHA512_DGST=$(grep -A 1 -E ' SHA512' /mnt/gentoo/*.tar.xz.DIGESTS.asc | grep -vE '(^#)|(CONTENTS)|(^-)' | awk '{ print $1 }')

  if [ -n "${GOOD_SHA512_DGST}" ]; then
    if [ "${SHA512_DGST}" != "${GOOD_SHA512_DGST}" ]; then
      echo "Bad SHA512 Checksum."
      exit 1
    fi
  else
    echo "SHA512 checksum was missing from the digest"
    exit 1
  fi

  GOOD_WHRLPL_DGST=$(grep -A 1 -E ' WHIRLPOOL' /mnt/gentoo/*.tar.xz.DIGESTS.asc | grep -vE '(^#)|(CONTENTS)|(^-)' | awk '{ print $1 }')
  WHRLPL_DGST=$(openssl dgst -r -whirlpool /mnt/gentoo/*.tar.xz | awk '{ print $1 }')

  if [ -n "${GOOD_WHRLPL_DGST}" ]; then
    if [ "${WHRLPL_DGST}" != "${GOOD_WHRLPL_DGST}" ]; then
      echo "Bad Whirlpool Checksum."
      exit 1
    fi
  else
    echo "Whirlpool checksum was missing from the digest"
    exit 1
  fi

  if [ -n "${NFS_SOURCE}" ]; then
    mkdir -p /mnt/nfs_source/reference_files/
    cp /mnt/gentoo/*.tar.xz /mnt/nfs_source/reference_files/stage4-amd64-hardened+minimal-nomultilib.tar.xz
  fi
fi

if [ "${LOCAL}" == "yes" ]; then
  tar -xpf /mnt/nfs_source/reference_files/stage4-amd64-hardened+minimal-nomultilib.tar.xz -C /mnt/gentoo
else
  tar -xpf /mnt/gentoo/*.tar.xz -C /mnt/gentoo
  rm -f /mnt/gentoo/*.tar.xz*
fi

# This needs to be a symlink and isn't in the stage... This was causing some
# installation issues so I have to migrate it by hand...
mv /mnt/gentoo/lib/* /mnt/gentoo/lib64/
rmdir /mnt/gentoo/lib
ln -s lib64 /mnt/gentoo/lib

# Remove the trash kernels that come with the stage
rm -rf /mnt/gentoo/boot/*
