#!/bin/bash

set -ex

# Expects to be run from the OpenWrt buildroot, after `make`.
docker import - meshbox-base < bin/x86/openwrt-x86-generic-Generic-rootfs.tar.gz
docker build -t meshbox feeds/meshbox/docker/

# Start the container, and make sure it gets killed.
container=$(docker run -d meshbox)
trap "docker kill $container" EXIT

# Prevent /sbin/init from starting cjdroute, and generate a config.
docker exec $container /etc/init.d/cjdns disable
docker exec $container /etc/uci-defaults/cjdns

# Get the IPv6 address, and the container's PID.
ipv6=$(docker exec $container uci get cjdns.cjdns.ipv6)
pid=$(docker inspect -f '{{.State.Pid}}' $container)

# Create the TUN interface, so that the container can receive ICMP pings.
# Requires sudo permissions for docker/make-tun.sh
#   lars  ALL=NOPASSWD: /path/to/openwrt/feeds/meshbox/docker/make-tun.sh
docker exec $container /bin/sh -c "mkdir /dev/net && ln -s /dev/tun /dev/net/tun"
ifname=$(sudo feeds/meshbox/docker/make-tun.sh $pid $ipv6)
docker exec $container /bin/sh -c "uci set cjdns.cjdns.tun_device=$ifname"
docker exec $container /bin/sh -c "uci changes && uci commit"

# Re-enable cjdns, assuming that /sbin/init hasn't finished yet and will
# start cjdns.
docker exec $container /etc/init.d/cjdns enable

# This is the actual test, which makes sure that cjdns started correctly,
# and auto-peering is enabled. Fail if we don't receive a pong within 30 secs.
ping6 -w 30 -c 1 $ipv6
