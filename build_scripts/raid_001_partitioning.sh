#/bin/bash

. ./_config.sh
. ./_error_handling.sh

# TODO: These should come from the common config file but while I'm getting
# this to work I'm going to hardcode these here...
DISK_ONE="/dev/vda"
DISK_TWO="/dev/vdb"

PARTED_BASE_ONE_CMD="/usr/sbin/parted ${DISK_ONE} --script --align optimal --machine --"
PARTED_BASE_TWO_CMD="/usr/sbin/parted ${DISK_TWO} --script --align optimal --machine --"

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

if [ ! -b ${DISK_ONE} ]; then
  echo "Configured disk one doesn't exist."
  exit 1
fi

if [ ! -b ${DISK_TWO} ]; then
  echo "Configured disk one doesn't exist."
  exit 1
fi

# We need to clear and reset the partition tables
/bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK_ONE} oflag=sync
${PARTED_BASE_ONE_CMD} mklabel gpt

/bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK_TWO} oflag=sync
${PARTED_BASE_TWO_CMD} mklabel gpt

# Identify the size of the disks we're working with
DISK_ONE_SIZE="$(
  ${PARTED_BASE_ONE_CMD} unit MiB print |
  cut -d : -f 2 |
  grep -oE '[0-9]+'
)"

DISK_TWO_SIZE="$(
  ${PARTED_BASE_TWO_CMD} unit MiB print |
  cut -d : -f 2 |
  grep -oE '[0-9]+'
)"

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

# Remove any partition headers on the individual partitions, this is simply for
# consistency when running this on a disk that had an existing partition table
# (usually only identical ones are problems).
dd if=/dev/zero bs=1M count=1 of=${DISK_ONE}1 oflag=sync status=none
dd if=/dev/zero bs=1M count=1 of=${DISK_ONE}2 oflag=sync status=none
dd if=/dev/zero bs=1M count=16 of=${DISK_ONE}3 oflag=sync status=none

dd if=/dev/zero bs=1M count=1 of=${DISK_TWO}1 oflag=sync status=none
dd if=/dev/zero bs=1M count=1 of=${DISK_TWO}2 oflag=sync status=none
dd if=/dev/zero bs=1M count=16 of=${DISK_TWO}3 oflag=sync status=none

# Create our raid array
mdadm --create /dev/md0 --level=raid1 --raid-devices=2 --metadata=1.2 ${DISK_ONE}3 ${DISK_TWO}3 &> /dev/null
/bin/dd bs=1M count=4 status=none if=/dev/zero of=/dev/md0 oflag=sync
PARTED_BASE_RAID_CMD="/usr/sbin/parted /dev/md0 --script --align optimal --machine --"

# Things that need to be added to handle the raid array inside the chroot later on...
#
#   emerge sys-fs/mdadm
#   rc-update add mdraid boot
#   mdadm --examine --scan >> /etc/mdadm.conf

${PARTED_BASE_RAID_CMD} mklabel gpt
${PARTED_BASE_RAID_CMD} unit MiB mkpart system 1 -1

# Format our base partitions
mkfs.vfat -F 32 -n EFI ${DISK_ONE}2 > /dev/null

pvcreate -ff -y --zero y /dev/md0p1 > /dev/null
vgcreate system /dev/md0p1 > /dev/null

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
