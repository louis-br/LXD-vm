#!/bin/bash
INTERFACE="wlxdc35f1dc4509"
BRIDGE="br0"
TAP="tap0"

NETWORK=192.168.53.0
MASK=24
GATEWAY=192.168.53.1
DHCPRANGE=192.168.53.2,192.168.53.254

set -x

start_dnsmasq() {
    dnsmasq \
        --strict-order \
        --except-interface=lo \
        --interface="$TAP" \
        --listen-address="$GATEWAY" \
        --bind-interfaces \
        --dhcp-range="$DHCPRANGE" \
        --conf-file="" \
        --pid-file="/var/run/qemu-dnsmasq-$TAP.pid" \
        --dhcp-leasefile="/var/run/qemu-dnsmasq-$TAP.leases" \
        --dhcp-no-override
}

start_nat() {
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o "$INTERFACE" -j MASQUERADE
    iptables -I FORWARD 1 -i "$TAP" -j ACCEPT
    iptables -I FORWARD 1 -o "$TAP" -m state --state RELATED,ESTABLISHED -j ACCEPT
}

ip tuntap add "$TAP" mode tap
ip addr add "$GATEWAY/$MASK" dev "$TAP"
ip link set up dev "$TAP"
#ip link add name "$BRIDGE" type bridge
#ip link set "$TAP" master "$BRIDGE"
#ip link set up dev "$BRIDGE"

start_nat

#ip addr flush dev "$INTERFACE"
#ip link set "$INTERFACE" master "$BRIDGE"
#ip link set up dev "$INTERFACE"
#dhclient -v "$INTERFACE"

start_dnsmasq