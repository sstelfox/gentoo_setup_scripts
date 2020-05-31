#/bin/bash

. ./_config.sh
. ./_error_handling.sh

# Seems like swap is still a good idea... Fedora recommendation is (seems
# reasonable):
#
# | RAM           | Swap   |
# | ------------- | ------ |
# | <= 4Gb        | 2Gb    |
# | 4Gb - 16Gb    | 4Gb    |
# | 16Gb - 64Gb   | 8Gb    |
# | 64Gb - 256Gb  | 16Gb   |
# | 256Gb - 512Gb | 32Gb   |
#
# Partition table using GPT:
#
# * 512MiB EFI partition
# * Remaining drive -> LVM
# * LVM -> root (whatever is left)
# * LVM -> swap (based on table above)

if [ "${RAID}" = "yes" ]; then
  DISK_ONE="$(echo '${DISK}' | awk '{ print $1 }')"
  DISK_TWO="$(echo '${DISK}' | awk '{ print $2 }')"

  if [ ! -b ${DISK_ONE} ]; then
    echo "Configured disk one doesn't exist."
    exit 1
  fi

  if [ ! -b ${DISK_TWO} ]; then
    echo "Configured disk one doesn't exist."
    exit 1
  fi

  PARTED_BASE_ONE_CMD="/usr/sbin/parted ${DISK_ONE} --script --align optimal --machine --"
  PARTED_BASE_TWO_CMD="/usr/sbin/parted ${DISK_TWO} --script --align optimal --machine --"

  # We need to clear and reset the partition tables
  /bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK_ONE} oflag=sync
  ${PARTED_BASE_ONE_CMD} mklabel gpt

  /bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK_TWO} oflag=sync
  ${PARTED_BASE_TWO_CMD} mklabel gpt

  # Create the actual partitions, the last will the a raid partition, while the
  # non-raid partitions are not fully setup on to the second one, since raid
  # partitions have to be the same size we would loose the space on the second
  # disk anyway and having the partitions setup identially can be useful in case
  # we need to use the mirror as a full restoration disk.
  ${PARTED_BASE_ONE_CMD} unit MiB mkpart bios 1 2 name 1 '"BIOS Grub"' set 1 bios_grub on
  ${PARTED_BASE_ONE_CMD} unit MiB mkpart boot 2 514 name 2 '"Boot"' set 2 boot on set 2 esp on
  ${PARTED_BASE_ONE_CMD} unit MiB mkpart raid 514 -1

  ${PARTED_BASE_TWO_CMD} unit MiB mkpart bios 1 2 name 1 '"BIOS Grub"' set 1 bios_grub on
  ${PARTED_BASE_TWO_CMD} unit MiB mkpart boot 2 514 name 2 '"Boot"' set 2 boot on set 2 esp on
  ${PARTED_BASE_TWO_CMD} unit MiB mkpart raid 514 -1

  # This is needed sometimes to get the partition devices to show up, this needs
  # to be allowed to fail as other partitions may be dirty (such as the boot
  # media).
  partprobe &> /dev/null || true

  # Validate each of the devices are present and block devices before continuing
  for disk in ${DISK_ONE} ${DISK_TWO}; do
    for part in 1 2 3; do
      if [ ! -b "${disk}${part}" ]; then
        echo "Unable to find expected block device: ${disk}${part}"
        exit 1
      fi
    done
  done

  PARTED_BASE_CMD="/usr/sbin/parted /dev/md0 --script --align optimal --machine --"

  ${PARTED_BASE_RAID_CMD} mklabel gpt
  ${PARTED_BASE_RAID_CMD} unit MiB mkpart system 1 -1

  # Format our base partitions
  mkfs.vfat -F 32 -n EFI ${DISK_ONE}2 > /dev/null

  /bin/dd bs=1M count=4 status=none if=/dev/zero of=/dev/md0p1 oflag=sync
  pvcreate -ff -y --zero y /dev/md0p1 > /dev/null
  vgcreate system --force --zero y /dev/md0p1 > /dev/null

  SYSTEM_PARTITION="/dev/md0p1"
else
  PARTED_BASE_CMD="/usr/sbin/parted ${DISK} --script --align optimal --machine --"

  if [ ! -b ${DISK} ]; then
    echo "Configured disk doesn't exist."
    exit 1
  fi

  # We need to clear and reset the partition tabel
  /bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK} oflag=sync
  ${PARTED_BASE_CMD} mklabel gpt

  # Create the actual partitions, the last will be an LVM container for the root
  # and swap partition.
  ${PARTED_BASE_CMD} unit MiB mkpart bios 1 2 name 1 '"BIOS Grub"' set 1 bios_grub on
  ${PARTED_BASE_CMD} unit MiB mkpart boot 2 514 name 2 '"Boot"' set 2 boot on set 2 esp on
  ${PARTED_BASE_CMD} unit MiB mkpart system 514 -1

  # Remove any partition headers on the individual partitions, this is simply for
  # consistency when running this on a disk that had an existing partition table
  # (usually only identical ones are problems).
  dd if=/dev/zero bs=1M count=1 of=${DISK}1 oflag=sync status=none
  dd if=/dev/zero bs=1M count=1 of=${DISK}2 oflag=sync status=none
  dd if=/dev/zero bs=1M count=16 of=${DISK}3 oflag=sync status=none

  # Format our base partitions
  mkfs.vfat -F 32 -n EFI ${DISK}2 > /dev/null

  SYSTEM_PARTITION="${DISK}3"
fi

if [ "${ENCRYPTED}" = "yes" ]; then
  # In case we're in DEBUG mode, do not print out the disk passphrase
  set +o xtrace

  # Ensure we get the passphrase correct
  while true; do
    read -e -p "Encryption Passphrase: " -s -r DISK_PASSPHRASE
    echo
    read -e -p "Verify Encryption Passphrase: " -s -r VERIFY_PASSPHRASE
    echo

    if [ "${DISK_PASSPHRASE}" = "${VERIFY_PASSPHRASE}" ]; then
      echo "Verified."
      break
    else
      echo "Passphrases don't match. Please try again."
    fi
  done

  unset VERIFY_PASSPHRASE

  echo ${DISK_PASSPHRASE} | cryptsetup --verbose --cipher aes-xts-plain64 \
    --key-size 512 --hash sha512 --iter-time 2500 --use-urandom --batch-mode \
    --force-password luksFormat ${SYSTEM_PARTITION}

  echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards ${SYSTEM_PARTITION} crypt
  unset DISK_PASSPHRASE

  # This will re-enable debug mode if it was previously enabled and prevents
  # duplicating that logic here.
  . ./_error_handling.sh

  pvcreate -ff -y --zero y /dev/mapper/crypt > /dev/null
  vgcreate system /dev/mapper/crypt > /dev/null
else
  pvcreate -ff -y --zero y ${SYSTEM_PARTITION} > /dev/null
  vgcreate system ${SYSTEM_PARTITION} > /dev/null
fi

# Calculate how much RAM we have available to figure out what we need for
# swap.
RAM_SIZE="$(free -m | grep Mem | awk '{ print $2 }')"

# Calculate ideal swap partition size, this may not be the final size
if [ "${RAM_SIZE}" -lt "4096" ]; then
  SWAP_SIZE="2048"
elif [ "${RAM_SIZE}" -lt "16384" ]; then
  SWAP_SIZE="4096"
elif [ "${RAM_SIZE}" -lt "65536" ]; then
  SWAP_SIZE="8192"
elif [ "${RAM_SIZE}" -lt "262144" ]; then
  SWAP_SIZE="16384"
else
  SWAP_SIZE="32768"
fi

# Limit the size of the swap partition to 10% of whats left of the drive after
# the EFI and boot partitions are created
AVAILABLE_VG_SPACE="$(vgdisplay --units m system | grep 'VG Size' | awk '{ print $(NF-1) }')"
SWAP_LIMIT="$(echo "${AVAILABLE_VG_SPACE%.*} / 10" | bc -q)"
if [ "${SWAP_SIZE}" -gt "${SWAP_LIMIT}" ]; then
  SWAP_SIZE="${SWAP_LIMIT}"
fi

ROOT_SIZE="$(( ${AVAILABLE_VG_SPACE%.*} - ${SWAP_SIZE} ))"

# Note to self, I added the --yes flag based on a comment in the man page but
# it wasn't actually listed in the available options for lvcreate. This hasn't
# been tested and may break. I was trying to deal with the script still
# interactively asking me if I wanted to wipe the swap signature even with
# --wipesignatures y
lvcreate -L ${ROOT_SIZE}M --wipesignatures y --yes -n root system > /dev/null
lvcreate -l 100%FREE --wipesignatures y --yes -n swap system > /dev/null

# Just in case refresh our logical lists
lvscan > /dev/null

mkfs.xfs -q -f -L root /dev/mapper/system-root
mkswap -f /dev/mapper/system-swap > /dev/null

sync
