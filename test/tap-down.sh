#!/bin/bash
INTERFACE="wlxdc35f1dc4509"
BRIDGE="br0"
TAP="tap0"

set -x

stop_dnsmasq() {
    file="/var/run/qemu-dnsmasq-$TAP.pid"
    id=$(cat "$file")
    if [ $(ps -p "$id" -o comm=) == "dnsmasq" ]; then
        kill "$id"
        rm "$file"
    fi
}

stop_nat() {
    echo 0 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -D POSTROUTING -o "$INTERFACE" -j MASQUERADE
    iptables -D FORWARD -i "$TAP" -j ACCEPT
    iptables -D FORWARD -o "$TAP" -m state --state RELATED,ESTABLISHED -j ACCEPT
}

ip link delete "$TAP"

stop_dnsmasq
stop_nat

#dhclient -v "$INTERFACE"