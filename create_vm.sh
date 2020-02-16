#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

function error_handler() {
  echo "Error occurred in ${3} executing line ${1} with status code ${2}"
  echo "The pipe status values were: ${4}"
}

# Please note basename... is intentionally at the end as it's a command that
# will effect the value of '$?'
trap 'error_handler ${LINENO} $? "$(basename ${BASH_SOURCE[0]})" "${PIPESTATUS[*]}"' ERR

# Log all commands before they're executed for debugging purposes
if [ -n "${DEBUG:-}" ]; then
  set -o xtrace
fi

if [ ${EUID} != 0 ]; then
  echo "This script is expecting to run as root."
  exit 1
fi

# When downloading the Arch ISO, a mirror will be randomly selected from this country. An error will result if the provided country doesn't 
export ARCH_MIRROR_COUNTRY="United States"

# The Arch Linux ISO is strictly better than the Gentoo install ISO as it
# supports UEFI, installation over serial, and has all the tools we need for
# the initial partitioning and setup before we switch into our Gentoo base.
#
# Once we're in our gentoo chroot the root ISO doesn't matter anymore. We start
# out by checking if we have an Arch ISO, and if not putting it in the
# appropriate directory.

# The arch ISOs are referenced by the current month. We'll use this to make
# sure we have a current copy of the ISO and if not to pull the appropriate one
# down.
CURRENT_ARCH_DATE="$(date '+%Y.%m.01')"

if [ ! -f "/var/lib/libvirt/images/archlinux-${CURRENT_ARCH_DATE}-x86_64.iso" ]; then
  echo "Do not have the current ArchLinux install ISO... Attempting to download it..."

  curl -s https://www.archlinux.org/mirrorlist/all/https/ > /tmp/arch_mirrors.txt

  if ! grep -q "${ARCH_MIRROR_COUNTRY}" /tmp/arch_mirrors.txt; then
    echo "Provided country '${ARCH_MIRROR_COUNTRY}' isn't present in the mirror file"
    exit 1
  fi

  SELECTED_ARCH_MIRROR="$(awk "/## ${ARCH_MIRROR_COUNTRY}/,/^$/" /tmp/arch_mirrors.txt | awk '/#Server/ { print $3 }' | sort -R | head -n 1)"
  REAL_ARCH_MIRROR_URL="$(echo ${SELECTED_ARCH_MIRROR} | sed "s^\$repo/os/\$arch^iso/${CURRENT_ARCH_DATE}^")"

  echo "Choosing '${REAL_ARCH_MIRROR_URL}' as the Arch mirror"

  pushd /var/lib/libvirt/images/ &> /dev/null

  echo "Beginning download..."
  wget --quiet --show-progress --progress=bar ${REAL_ARCH_MIRROR_URL}/archlinux-${CURRENT_ARCH_DATE}-x86_64.iso
  wget --quiet --show-progress --progress=bar ${REAL_ARCH_MIRROR_URL}/archlinux-${CURRENT_ARCH_DATE}-x86_64.iso.sig
  wget --quiet --show-progress --progress=bar ${REAL_ARCH_MIRROR_URL}/md5sums.txt
  wget --quiet --show-progress --progress=bar ${REAL_ARCH_MIRROR_URL}/sha1sums.txt

  echo "Validating the file integrities..."
  sha1sum --ignore-missing --status --strict --quiet --check sha1sums.txt &> /dev/null
  md5sum --ignore-missing --status --strict --quiet --check md5sums.txt &> /dev/null

  # Ensure that the ISO is authentic, this auto-key-retrieval isn't great as a
  # malicous actor could simply correctly sign the ISO with any public key and
  # this will pass... So it's important to check that the key used is one of
  # the correct ones. This seems like it needs to be manual for now...
  gpg2 --auto-key-retrieve --verify archlinux-${CURRENT_ARCH_DATE}-x86_64.iso.sig

  echo
  echo "If the key above is valid press any key, otherwise Ctrl-C out of this..."
  read -n 1
  echo

  # Clean up the files we don't need anymore
  rm -f archlinux-${CURRENT_ARCH_DATE}-x86_64.iso.sig md5sums.txt sha1sums.txt

  popd &> /dev/null
fi

if !ip link show dev br0 &> /dev/null; then
  echo "Could not find expected bridge for guest networking."
  exit 1
fi

echo "The boot menu will appear shortly after this..."
echo "Remember to edit the boot entry adding 'console=ttyS0' to the end of boot entry"
echo "Press any key to begin..."
read -n 1
echo

virt-install \
  --connect qemu:///system \
  --name gentoo-test-$(uuidgen) \
  --ram 2048 --vcpus 3 --check-cpu \
  --arch x86_64 \
  --hvm --virt-type kvm \
  --security "type=dynamic" \
  --os-type linux --os-variant archlinux \
  --graphics none \
  --memballoon virtio \
  --network "bridge=br0" \
  --boot "uefi,bootmenu.enable=on,bios.useserial=on" \
  --console "pty,target_type=virtio" \
  --cdrom "/var/lib/libvirt/images/archlinux-${CURRENT_ARCH_DATE}-x86_64.iso" \
  --disk "pool=default,size=20,sparse=true,format=qcow2" \
  --tpm "backend.type=emulator,backend.version=2.0"

# For the tpm flag I may want to add in the argument model=tpm-crb, the default
# should be model=tpm-tis. There is another field "encryption" that exists in
# the libvirt XML which I should verify is being randomly generated and
# actually set.
