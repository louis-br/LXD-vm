#!/bin/bash

#set -x

export LABEL="rootfs"
export BOOTLOADER="grub"
export TOTAL_SIZE="2500MB"
export EFI_SIZE="261MiB"
export UUID="dddddddd-0000-cccc-eeee-222222222222"

export VMLINUZ="/boot/vmlinuz-linux"
export INITRAMFS="/boot/initramfs-linux.img"
export KERNEL_PARAMETERS="rd.live.overlay=UUID=${UUID} rd.live.overlay.overlayfs=1 ${KERNEL_PARAMETERS}"
export KERNEL_PARAMETERS="console=ttyS0 root=live:UUID=${UUID} rootfstype=auto init=/sbin/init rw ${KERNEL_PARAMETERS}" #ext4

sudo podman build --tag=podman2vm-arch . || exit 1

#sudo podman build   --tag=podman2vm-arch \
#                    --file=Containerfile.import \
#                    --volume="$PWD/containers/LXD-openwrt/output:/output" \
#                    --no-cache \
#                    . || exit 1

sudo podman create --name=podman2vm-arch podman2vm-arch || exit 1
mnt=$(sudo podman mount podman2vm-arch)

mkdir --parents output/

export ROOTFS="$mnt"
export OUTPUT="$PWD/output"

cd podman2vm
./build.sh

sudo podman umount podman2vm-arch
sudo podman container rm podman2vm-arch

echo "Done building. "
wait
echo