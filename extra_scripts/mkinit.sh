#!/bin/bash

set -o errexit

INITRAMFS_PKG_ROOT=/usr/src/initpkgs
INITRAMFS_DIR=/usr/src/initramfs

rm -rf ${INITRAMFS_DIR}
mkdir -p ${INITRAMFS_DIR}

PYTHON_TARGETS="python3_6" FEATURES="-*" USE="-* ipv6 make-symlinks python selinux static" emerge --root=${INITRAMFS_PKG_ROOT} --root-deps=rdeps --sysroot=${INITRAMFS_PKG_ROOT} sys-apps/busybox
PYTHON_TARGETS="python3_6" FEATURES="-*" USE="-* python selinux static static-libs thin udev" emerge --root=${INITRAMFS_PKG_ROOT} --root-deps=rdeps --sysroot=${INITRAMFS_PKG_ROOT} sys-fs/lvm2

#FEATURES="-*" USE="-* minimal multicall static" emerge --root=${INITRAMFS_PKG_ROOT} --root-deps=rdeps --sysroot=${INITRAMFS_PKG_ROOT} net-misc/dropbear
#FEATURES="-*" USE="-* static" emerge --root=${INITRAMFS_DIR} --root-deps=rdeps --sysroot=${INITRAMFS_PKG_ROOT} dev-util/strace

mkdir -p /usr/src/initramfs/{bin,dev,etc,proc,root,sbin,sys,sysroot,tmp}

# May need tty,vda...
mknod --context=system_u:object_r:console_device_t --mode=u=rw,g=r,o=r ${INITRAMFS_DIR}/dev/console c 5 1
mknod --context=system_u:object_r:kmsg_device_t --mode=u=rw,g=r,o=r ${INITRAMFS_DIR}/dev/kmsg c 1 11
mknod --context=system_u:object_r:null_device_t --mode=u=rw,g=rw,o=rw ${INITRAMFS_DIR}/dev/null c 1 3
mknod --context=system_u:object_r:random_device_t --mode=u=rw,g=rw,o=rw ${INITRAMFS_DIR}/dev/random c 1 8
mknod --context=system_u:object_r:urandom_device_t --mode=u=rw,g=rw,o=rw ${INITRAMFS_DIR}/dev/urandom c 1 9

cat << 'EOF' > ${INITRAMFS_DIR}/init
#!/bin/busybox sh

mount -t proc none /proc
mount -t sysfs none /sys

exec sh
EOF

chmod +x ${INITRAMFS_DIR}/init
