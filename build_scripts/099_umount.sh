#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

mount | grep -q /mnt/gentoo/dev && umount -l /mnt/gentoo/dev
mount | grep -q /mnt/gentoo/proc && umount /mnt/gentoo/proc
mount | grep -q /mnt/gentoo/run && umount -l /mnt/gentoo/run
mount | grep -q /mnt/gentoo/sys && umount -l /mnt/gentoo/sys

mount | grep -q '/mnt/gentoo/var/cache' && umount -l /mnt/gentoo/var/cache
mount | grep -q '/mnt/gentoo/var/db/repos' && umount -l /mnt/gentoo/var/db/repos

mount | grep -q boot && umount -f /mnt/gentoo/boot
mount | grep -q gentoo && umount -rl /mnt/gentoo || true

swapoff -a
sync

# When these fail to dismount, I can identify what processes are holding them
# open with this:
# grep system /proc/*/mounts | grep -vE '(cgroup|systemd)'

# These processes are problematic and hold open the mounts despite having
# nothing to do with them... Fucking systemd...
systemctl stop havaged.service
systemctl stop systemd-logind.service                                                                                                │
systemctl stop systemd-udevd.service

lvchange -a n system

[ -b /dev/mapper/crypt ] && cryptsetup luksClose /dev/mapper/crypt || true
