#!/bin/bash

set -o errexit

INITRAMFS_PKG_ROOT=/usr/src/initpkgs
INITRAMFS_DIR=/usr/src/initramfs

rm -rf ${INITRAMFS_DIR} ${INITRAMFS_PKG_ROOT}

mkdir -p ${INITRAMFS_PKG_ROOT}

FEATURES="-*" USE="-* ipv6 make-symlinks python selinux static" emerge \
  --root=${INITRAMFS_PKG_ROOT} --root-deps=rdeps \
  --sysroot=${INITRAMFS_PKG_ROOT} sys-apps/busybox

# Note: When I get to this I'm going to likely need the busybox ifdown, ifup,
# ip, ipaddr, iplink, ipneigh, iproute, nameif, route, udhcpc, udhcpc6,
# vconfig
#FEATURES="-*" USE="-* minimal multicall static" emerge \
#  --root=${INITRAMFS_PKG_ROOT} --root-deps=rdeps \
#  --sysroot=${INITRAMFS_PKG_ROOT} net-misc/dropbear


# The binaries that were present in the old init:
#
# /bin: bash,cat,chown,chroot,cp,dmesg,findmnt,gzip,kmod,ln,ls,mkdir,mknod,mount,
#       mv,readlink,rm,rmdir,sed,sleep,stty,tr,udevadm,umount,uname
# /lib/udev: ata_id, cdrom_id, console_init, scsi_id
# /sbin: blkid, cryptroot-ask, cryptsetup, dmeventd, dmsetup, e2fsck, fsck,
#        fsck.cramfs, fsck.minix, fsck.xfs, initqueue, insmodpost.sh, loginit,
#        lvm, lvm_scan, pdata_tools, probe-keydev, rdsosreport, switch_root,
#        tracekomem, udevd, xfs_repair
# /usr/bin: flock, kbd_mode, less, loadkeys, setfont, setsid
# /usr/sbin: capsh, setenforce, xfs_db, xfs_metadump


# The binaries I think I may care about and are covered by busybox:
#
# /bin: chroot, findmnt, udevadm
# /lib/udev: ata_id, cdrom_id, console_init, scsi_id
# /sbin: cryptroot-ask, cryptsetup, dmeventd, dmsetup, fsck.xfs, initqueue,
#        loginit, lvm, lvm_scan, pdata_tools, probe-keydev, rdsosreport,
#        tracekomem, udevd, xfs_repair
# /usr/bin: loadkeys
# /usr/sbin: capsh, xfs_db, xfs_metadump

mkdir -p ${INITRAMFS_DIR}/{bin,dev,etc,lib64,proc,root,sbin,sys,sysroot,tmp,var/tmp}
chmod 1777 ${INITRAMFS_DIR}/tmp
chmod 1777 ${INITRAMFS_DIR}/var/tmp

# May need tty,vda...
mknod --context=system_u:object_r:console_device_t --mode=u=rw,g=r,o=r ${INITRAMFS_DIR}/dev/console c 5 1
mknod --context=system_u:object_r:kmsg_device_t --mode=u=rw,g=r,o=r ${INITRAMFS_DIR}/dev/kmsg c 1 11
mknod --context=system_u:object_r:null_device_t --mode=u=rw,g=rw,o=rw ${INITRAMFS_DIR}/dev/null c 1 3
mknod --context=system_u:object_r:random_device_t --mode=u=rw,g=rw,o=rw ${INITRAMFS_DIR}/dev/random c 1 8
mknod --context=system_u:object_r:urandom_device_t --mode=u=rw,g=rw,o=rw ${INITRAMFS_DIR}/dev/urandom c 1 9

cp ${INITRAMFS_PKG_ROOT}/bin/busybox ${INITRAMFS_DIR}/bin/busybox

pushd ${INITRAMFS_DIR}/bin &> /dev/null
ln -s ../bin/busybox cat
#ln -s ../bin/busybox chmod
#ln -s ../bin/busybox chown
#ln -s ../bin/busybox cp
ln -s ../bin/busybox dmesg
ln -s ../bin/busybox flock
#ln -s ../bin/busybox gzip
#ln -s ../bin/busybox ln
ln -s ../bin/busybox less
ln -s ../bin/busybox ls
#ln -s ../bin/busybox mkdir
ln -s ../bin/busybox mknod
ln -s ../bin/busybox mount
ln -s ../bin/busybox mv
#ln -s ../bin/busybox readlink
#ln -s ../bin/busybox rm
#ln -s ../bin/busybox rmdir
#ln -s ../bin/busybox sed
#ln -s ../bin/busybox sleep
ln -s ../bin/busybox stty
#ln -s ../bin/busybox tr
ln -s ../bin/busybox umount
ln -s ../bin/busybox uname
popd &> /dev/null

pushd ${INITRAMFS_DIR}/sbin &> /dev/null
ln -s ../bin/busybox blkid
#ln -s ../bin/busybox getenforce
#ln -s ../bin/busybox getsebool
#ln -s ../bin/busybox sestatus
ln -s ../bin/busybox setenforce
#ln -s ../bin/busybox setsebool
ln -s ../bin/busybox switch_root
popd &> /dev/null

#mkdir -p ${INITRAMFS_DIR}/usr/bin
#pushd ${INITRAMFS_DIR}/usr/bin &> /dev/null
#ln -s ../../bin/busybox env
#popd &> /dev/null

touch ${INITRAMFS_DIR}/etc/ld.so.conf
chmod 0644 ${INITRAMFS_DIR}/etc/ld.so.conf

touch ${INITRAMFS_DIR}/etc/profile.env
chmod 0644 ${INITRAMFS_DIR}/etc/profile.env

cp -a /bin/chroot ${INITRAMFS_DIR}/bin/chroot
cp -a /lib64/libc.so.6 ${INITRAMFS_DIR}/lib64/libc.so.6
cp -a /lib64/ld-linux-x86-64.so.2 ${INITRAMFS_DIR}/lib64/ld-linux-x86-64.so.2

cp -a /sbin/lvm ${INITRAMFS_DIR}/sbin/lvm
cp -a /lib64/libdevmapper-event.so.1.02 ${INITRAMFS_DIR}/lib64/libdevmapper-event.so.1.02
cp -a /lib64/libudev.so.1 ${INITRAMFS_DIR}/lib64/libudev.so.1
cp -a /lib64/libdl.so.2 ${INITRAMFS_DIR}/lib64/libdl.so.2
cp -a /lib64/libblkid.so.1 ${INITRAMFS_DIR}/lib64/libblkid.so.1
cp -a /lib64/libdevmapper.so.1.02 ${INITRAMFS_DIR}/lib64/libdevmapper.so.1.02
cp -a /lib64/libaio.so.1 ${INITRAMFS_DIR}/lib64/libaio.so.1
cp -a /lib64/libreadline.so.7 ${INITRAMFS_DIR}/lib64/libreadline.so.7
#cp -a /lib64/libc.so.6 ${INITRAMFS_DIR}/lib64/libc.so.6
cp -a /lib64/libpthread.so.0 ${INITRAMFS_DIR}/lib64/libpthread.so.0
cp -a /lib64/libselinux.so.1 ${INITRAMFS_DIR}/lib64/libselinux.so.1
#cp -a /lib64/ld-linux-x86-64.so.2 ${INITRAMFS_DIR}/lib64/ld-linux-x86-64.so.2
cp -a /lib64/libuuid.so.1 ${INITRAMFS_DIR}/lib64/libuuid.so.1
cp -a /lib64/libm.so.6 ${INITRAMFS_DIR}/lib64/libm.so.6
cp -a /lib64/libtinfow.so.6 ${INITRAMFS_DIR}/lib64/libtinfow.so.6
cp -a /lib64/libpcre.so.1 ${INITRAMFS_DIR}/lib64/libpcre.so.1

cp -a /sbin/fsck.xfs ${INITRAMFS_DIR}/sbin/fsck.xfs

# /bin: bash, findmnt, kmod, udevadm
# /lib/udev: ata_id, cdrom_id, console_init, scsi_id
# /sbin: cryptroot-ask, cryptsetup, dmeventd, dmsetup, initqueue,
#        insmodpost.sh, loginit, lvm_scan, pdata_tools, probe-keydev,
#        rdsosreport, tracekomem, udevd, xfs_repair
# /usr/bin: kbd_mode, loadkeys, setfont
# /usr/sbin: capsh, xfs_db

cp /sbin/udevd ${INITRAMFS_DIR}/sbin/udevd
#cp -a /lib64/libblkid.so.1 ${INITRAMFS_DIR}/lib64/libblkid.so.1
#cp -a /lib64/libselinux.so.1 ${INITRAMFS_DIR}/lib64/libselinux.so.1
cp -a /lib64/libkmod.so.2 ${INITRAMFS_DIR}/lib64/libkmod.so.2
#cp -a /lib64/libc.so.6 ${INITRAMFS_DIR}/lib64/libc.so.6
#cp -a /lib64/ld-linux-x86-64.so.2 ${INITRAMFS_DIR}/lib64/ld-linux-x86-64.so.2
#cp -a /lib64/libuuid.so.1 ${INITRAMFS_DIR}/lib64/libuuid.so.1
#cp -a /lib64/libpcre.so.1 ${INITRAMFS_DIR}/lib64/libpcre.so.1
cp -a /lib64/libdl.so.2 ${INITRAMFS_DIR}/lib64/libdl.so.2
#cp -a /lib64/libpthread.so.0 ${INITRAMFS_DIR}/lib64/libpthread.so.0
cp -a /lib64/libz.so.1 ${INITRAMFS_DIR}/lib64/libz.so.1

#mkdir -p ${INITRAMFS_DIR}/usr/bin
#cp -a /usr/bin/setsid ${INITRAMFS_DIR}/usr/bin/setsid
#cp -a /lib64/libc.so.6 ${INITRAMFS_DIR}/lib64/libc.so.6
#cp -a /lib64/ld-linux-x86-64.so.2 ${INITRAMFS_DIR}/lib64/ld-linux-x86-64.so.2

mkdir -p ${INITRAMFS_DIR}/usr/sbin
cp -a /usr/sbin/xfs_metadump ${INITRAMFS_DIR}/usr/sbin/xfs_metadump

cat << 'EOF' > ${INITRAMFS_DIR}/etc/group
tty:x:5:
uucp:x:14:uucp
kmem:x:9:
input:x:97:
video:x:27:root
audio:x:18:
lp:x:7:lp
disk:x:6:root,adm
cdrom:x:19:
tape:x:26:root
kvm:x:78:
dialout:x:20:
floppy:x:11:root
EOF

cat << 'EOF' > ${INITRAMFS_DIR}/etc/passwd
root:x:0:0::/root:/bin/sh
nobody:x:65534:65534:nobody:/var/empty:/bin/false
EOF

cat << 'EOF' > ${INITRAMFS_DIR}/init
#!/bin/busybox sh

mount -t proc none /proc
mount -t sysfs none /sys

exec sh
EOF

chmod +x ${INITRAMFS_DIR}/init
