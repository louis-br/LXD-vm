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

export_lxd-arch() {
    sudo podman create --name=lxd-arch lxd-arch || exit 1
    lxdmnt=$(sudo podman mount lxd-arch)

    echo "Exporting tar..."
    sudo tar --create --overwrite --absolute-names --file output/lxd-arch-meta.tar --directory containers/lxd-arch/metadata $(ls --almost-all containers/lxd-arch/metadata)  || exit 1
    sudo tar --create --overwrite --absolute-names --file output/lxd-arch.tar --directory "$lxdmnt" $(sudo ls --almost-all "$lxdmnt") || exit 1
    echo "Done"

    sudo podman umount lxd-arch
    sudo podman container rm lxd-arch
}

sudo podman build --tag=lxd-arch containers/lxd-arch/ || exit 1
sudo podman build --tag=podman2vm-arch-base . || exit 1

export_lxd-arch
#pv --timer --eta --rate --bytes --progress containers/lxd-arch/pipes/rootfs > /dev/null
sudo podman build   --tag=podman2vm-arch \
                    --file=Containerfile.import \
                    --volume="$PWD/output:/output" \
                    --no-cache \
                    . || exit 1

#wait
#exit 0

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