#!/bin/bash

set -o errexit

# Alright here is what I'm doing to build this up, it's a slow reverse engineer
# and digging through various references I've built up over time.
#
# mkdir -p /tmp/init_tmp
# cd /tmp/init_tmp
# file /boot/initramfs-current.img
# lz4cat /boot/initramfs-current.img | cpio -mvid
# ls -l

mkdir -p /tmp/init/

FEATURES="-*" USE="-* ipv6 make-symlinks static" emerge --root=/tmp/init/ --root-deps=rdeps --sysroot=/tmp/init/ sys-apps/busybox
FEATURES="-*" USE="-* minimal multicall static" emerge --root=/tmp/init/ --root-deps=rdeps --sysroot=/tmp/init/ net-misc/dropbear

# While diagnosing some issues I found this to be useful:
FEATURES="-*" USE="-* static" emerge --root=/tmp/init/ --root-deps=rdeps --sysroot=/tmp/init/ dev-util/strace

mkdir -p /tmp/init/dev

# ls -l ./dev
# file /dev/console
# ls -lhZ /dev/console

mknod --context=system_u:object_r:console_device_t --mode=u=rw,g=r,o=r /tmp/init/dev/console c 5 1

# file /dev/kmsg
# ls -lhZ /dev/kmsg

mknod --context=system_u:object_r:kmsg_device_t --mode=u=rw,g=r,o=r /tmp/init/dev/kmsg c 1 11

# ...

mknod --context=system_u:object_r:null_device_t --mode=u=rw,g=rw,o=rw /tmp/init/dev/null c 1 3
mknod --context=system_u:object_r:random_device_t --mode=u=rw,g=rw,o=rw /tmp/init/dev/random c 1 8
mknod --context=system_u:object_r:urandom_device_t --mode=u=rw,g=rw,o=rw /tmp/init/dev/urandom c 1 9

chown -R root:root /tmp/init/dev

cd /tmp/init
find . | cpio -ov | lz4c > /tmp/built_init
