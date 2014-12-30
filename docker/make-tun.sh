#!/bin/bash

set -ex

pid=$1
ipv6=$2
ifname="cjdns-smoketest"

ip tuntap del mode tun dev $ifname
ip tuntap add mode tun dev $ifname

mkdir /var/run/netns || true
ln -s /proc/$pid/ns/net /var/run/netns/$pid

ip link set $ifname netns $pid
ip netns exec $pid ip addr add $ipv6/8 dev $ifname
ip netns exec $pid ip link set mtu 1312 dev $ifname
ip netns exec $pid ip link set $ifname up

echo $ifname
