#!/bin/bash

#set -x

export LABEL="rootfs"
export BOOTLOADER="grub"
export TOTAL_SIZE="8GB"
export EFI_SIZE="261MiB"
export UUID="dddddddd-0000-cccc-eeee-222222222222"

export VMLINUZ="/boot/vmlinuz-linux"
export INITRAMFS="/boot/initramfs-linux.img"
export KERNEL_PARAMETERS="console=ttyS0 rootfstype=ext4 root=UUID=${UUID} init=/sbin/init rw ${KERNEL_PARAMETERS}"

sudo podman build --tag=podman2vm-arch-base . || exit 1

sudo podman build   --tag=podman2vm-arch \
                    --file=Containerfile.import \
                    --volume="$PWD/containers/LXD-X-server/output:/output" \
                    --no-cache \
                    . || exit 1

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