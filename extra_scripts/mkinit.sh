#!/bin/bash

set -o errexit

INITRAMFS_DIR=/usr/src/initramfs

rm -rf ${INITRAMFS_DIR}
mkdir -p ${INITRAMFS_DIR}

FEATURES="-*" USE="-* ipv6 make-symlinks selinux static" emerge --root=${INITRAMFS_DIR} --root-deps=rdeps --sysroot=${INITRAMFS_DIR} sys-apps/busybox
FEATURES="-*" USE="-* selinux static thin udev" emerge --root=${INITRAMFS_DIR} --root-deps=rdeps --sysroot=${INITRAMFS_DIR} sys-fs/lvm2

#FEATURES="-*" USE="-* minimal multicall static" emerge --root=${INITRAMFS_DIR} --root-deps=rdeps --sysroot=${INITRAMFS_DIR} net-misc/dropbear
#FEATURES="-*" USE="-* static" emerge --root=${INITRAMFS_DIR} --root-deps=rdeps --sysroot=${INITRAMFS_DIR} dev-util/strace

mkdir -p /usr/src/initramfs/{dev,proc,root,sys,sysroot}

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
