TAP="tap0"

sudo qemu-system-x86_64 \
    -machine type=q35,accel=kvm \
    -enable-kvm \
    -cpu host \
    -smp sockets=1,cores=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}'),threads=2 \
    -device virtio-vga \
    -m 2048M \
    -bios /usr/share/ovmf/OVMF.fd \
    -device virtio-blk-pci,drive=disk0,bootindex=0 \
    -drive id=disk0,if=none,format=raw,file=../output/disk.img \
    -device e1000,netdev=net0 \
    -netdev tap,id=net0,ifname="$TAP",script=/home/user/LXD-vm/test/tap-up.sh,downscript=/home/user/LXD-vm/test/tap-down.sh \
    "$@"