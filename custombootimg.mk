LOCAL_PATH := $(call my-dir)

INITSH := $(LOCAL_PATH)/combinedroot/init.sh
BOOTREC_DEVICE := $(LOCAL_PATH)/combinedroot/bootrec-device
BOOTREC_LED := $(LOCAL_PATH)/combinedroot/bootrec-led

INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
$(INSTALLED_BOOTIMAGE_TARGET): $(PRODUCT_OUT)/kernel $(recovery_ramdisk) $(INSTALLED_RAMDISK_TARGET) $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/utilities/extract_elf_ramdisk $(MKBOOTIMG) $(MINIGZIP) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Boot image: $@")
	$(hide) mkdir -p $(PRODUCT_OUT)/combinedroot/sbin
	$(hide) cp -R $(PRODUCT_OUT)/root/logo.rle $(PRODUCT_OUT)/combinedroot/logo.rle
	$(hide) cp -R $(INITSH) $(PRODUCT_OUT)/combinedroot/sbin/init.sh
	$(hide) chmod 755 $(PRODUCT_OUT)/combinedroot/sbin/init.sh
	$(hide) ln -s sbin/init.sh $(PRODUCT_OUT)/combinedroot/init
	$(hide) cp $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(PRODUCT_OUT)/utilities/extract_elf_ramdisk $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(BOOTREC_DEVICE) $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(BOOTREC_LED) $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp -R $(PRODUCT_OUT)/recovery/root/sbin/* $(PRODUCT_OUT)/root/sbin/
	$(hide) cp -R $(LOCAL_PATH)/prebuilt/root/default.prop $(PRODUCT_OUT)/root/
	$(hide) cp -R $(LOCAL_PATH)/prebuilt/root/init.environ.rc $(PRODUCT_OUT)/root/
	$(hide) cp -R $(LOCAL_PATH)/recovery/init.rc $(PRODUCT_OUT)/recovery/root/
	$(hide) cp -R $(LOCAL_PATH)/recovery/runatboot.sh $(PRODUCT_OUT)/recovery/root/sbin/
	$(hide) rm -rf $(PRODUCT_OUT)/recovery/root/sbin/usbid_init.sh
	$(hide) $(MKBOOTFS) $(PRODUCT_OUT)/root/ > $(PRODUCT_OUT)/ramdisk.cpio
	$(hide) $(MKBOOTFS) $(PRODUCT_OUT)/recovery/root/ > $(PRODUCT_OUT)/ramdisk-recovery.cpio
	$(hide) cp -R $(PRODUCT_OUT)/ramdisk.cpio $(PRODUCT_OUT)/combinedroot/sbin/ramdisk.cpio
	$(hide) $(MKBOOTFS) $(PRODUCT_OUT)/combinedroot > $(PRODUCT_OUT)/combinedroot.cpio
	$(hide) cat $(PRODUCT_OUT)/combinedroot.cpio | gzip > $(PRODUCT_OUT)/combinedroot.fs
	$(hide) rm -rf $(PRODUCT_OUT)/system/bin/recovery
	$(hide) rm -rf $(PRODUCT_OUT)/boot.img
	$(hide) python $(LOCAL_PATH)/releasetools/mkelf.py -o $(PRODUCT_OUT)/kernel.elf $(PRODUCT_OUT)/kernel@0x00008000 $(PRODUCT_OUT)/combinedroot.fs@0x01000000,ramdisk $(LOCAL_PATH)/prebuilt/cmdline@cmdline
	$(hide) dd if=$(PRODUCT_OUT)/kernel.elf of=$(PRODUCT_OUT)/kernel.elf.bak bs=1 count=44
	$(hide) printf "\x04" >$(PRODUCT_OUT)/04
	$(hide) cat $(PRODUCT_OUT)/kernel.elf.bak $(PRODUCT_OUT)/04 > $(PRODUCT_OUT)/kernel.elf.bak2
	$(hide) rm -rf $(PRODUCT_OUT)/kernel.elf.bak
	$(hide) dd if=$(PRODUCT_OUT)/kernel.elf of=$(PRODUCT_OUT)/kernel.elf.bak bs=1 skip=45 count=99
	$(hide) cat $(PRODUCT_OUT)/kernel.elf.bak2 $(PRODUCT_OUT)/kernel.elf.bak > $(PRODUCT_OUT)/kernel.elf.bak3
	$(hide) rm -rf $(PRODUCT_OUT)/kernel.elf.bak $(PRODUCT_OUT)/kernel.elf.bak2
	$(hide) cat $(PRODUCT_OUT)/kernel.elf.bak3 $(LOCAL_PATH)/prebuilt/elf.3 > $(PRODUCT_OUT)/kernel.elf.bak
	$(hide) rm -rf $(PRODUCT_OUT)/kernel.elf.bak3
	$(hide) dd if=$(PRODUCT_OUT)/kernel.elf of=$(PRODUCT_OUT)/kernel.elf.bak2 bs=16 skip=79
	$(hide) cat $(PRODUCT_OUT)/kernel.elf.bak $(PRODUCT_OUT)/kernel.elf.bak2 > $(PRODUCT_OUT)/kernel.elf.bak3
	$(hide) rm -rf $(PRODUCT_OUT)/kernel.elf.bak $(PRODUCT_OUT)/kernel.elf.bak2 $(PRODUCT_OUT)/kernel.elf $(PRODUCT_OUT)/04
	$(hide) mv $(PRODUCT_OUT)/kernel.elf.bak3 $(PRODUCT_OUT)/boot.img

INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
	$(recovery_ramdisk) \
	$(recovery_kernel)
	@echo ----- Making recovery image ------
	$(hide) $(MKBOOTIMG) -o $@ --kernel $(PRODUCT_OUT)/kernel --ramdisk $(PRODUCT_OUT)/ramdisk-recovery.img --cmdline '$(BOARD_KERNEL_CMDLINE)' --base $(BOARD_KERNEL_BASE) $(BOARD_MKBOOTIMG_ARGS)
	@echo ----- Made recovery image -------- $@
