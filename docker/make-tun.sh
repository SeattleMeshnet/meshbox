#!/bin/bash

set -ex

pid=$1
ipv6=$2

ip tuntap add mode tun
ifname=$(ip link | tail -n2 | cut -d":" -f2 | head -n1 | cut -d" " -f2)

mkdir /var/run/netns || true
ln -s /proc/$pid/ns/net /var/run/netns/$pid

ip link set $ifname netns $pid
ip netns exec $pid ip addr add $ipv6/8 dev $ifname
ip netns exec $pid ip link set mtu 1312 dev $ifname
ip netns exec $pid ip link set $ifname up

echo $ifname
