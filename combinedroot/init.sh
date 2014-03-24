#!/sbin/busybox sh
set +x
_PATH="$PATH"
export PATH=/sbin

busybox cd /
busybox date >>boot.txt
exec >>boot.txt 2>&1
busybox rm /init

# include device specific vars
source /sbin/bootrec-device

# create directories
busybox mkdir -m 755 -p /dev/block
busybox mkdir -m 755 -p /dev/input
busybox mkdir -m 555 -p /proc
busybox mkdir -m 755 -p /sys

# create device nodes
busybox mknod -m 600 /dev/block/mmcblk0 b 179 0
busybox mknod -m 600 ${BOOTREC_EVENT_NODE}
busybox mknod -m 666 /dev/null c 1 3

# mount filesystems
busybox mount -t proc proc /proc
busybox mount -t sysfs sysfs /sys

# trigger LED
busybox chmod 755 /sbin/bootrec-led
./sbin/bootrec-led

# keycheck
busybox cat ${BOOTREC_EVENT} > /dev/keycheck&
busybox sleep 3

# android ramdisk
load_image=/sbin/ramdisk.cpio

# boot decision
if [ -s /dev/keycheck ] || busybox grep -q warmboot=0x5502 /proc/cmdline ; then
	busybox echo 'RECOVERY BOOT' >>boot.txt

	# extract recovery ramdisk from fota partition
	busybox mknod -m 600 ${BOOTREC_FOTA_NODE}
	busybox mount -o remount,rw /
	busybox ln -sf /sbin/busybox /sbin/sh
	extract_elf_ramdisk -i ${BOOTREC_FOTA} -o /sbin/ramdisk-recovery.cpio -t / -c
	busybox rm /sbin/sh

	# check if ramdisk is extracted correctly
	if [ -e /sbin/ramdisk-recovery.cpio ]
	then
		# ramdisk extracted correctly
		load_image=/sbin/ramdisk-recovery.cpio
	else
		busybox echo 'RECOVERY DOES NOT EXIST' >>boot.txt
	fi
else
	busybox echo 'ANDROID BOOT' >>boot.txt
fi

# kill the keycheck process
busybox pkill -f "busybox cat ${BOOTREC_EVENT}"

busybox umount /proc
busybox umount /sys

busybox rm -fr /dev/*

# unpack the ramdisk image
# -u should be used to replace the static busybox with dynamically linked one.
busybox cpio -ui < ${load_image}

export PATH="${_PATH}"
exec /init
