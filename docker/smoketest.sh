#!/bin/bash

set -x

# Usage:
#   ./smoketest.sh $rootfs
#
# TODO: remove dockerfile, we don't need the setup

# Expects to be run from the OpenWrt buildroot, after `make`.
#
# 1. Creates an image based on bin/x86/openwrt-x86-generic-Generic-rootfs.tar.gz
# 2. Then starts two containers, and a TUN interface for each
# 3. Then sets up ETHInterface peering on the docker0 bridge
# 4. Then tries to ping in both directions
# 5. Succeeds, or times out after 30 seconds
# 6. Finally cleans up the containers and image

rootfs=$1

ipv6addr() {
  docker exec $1 uci get cjdns.cjdns.ipv6 || echo ""
}

cleanup() {
  docker kill $1 ; docker rm $1 ;
  docker kill $2 ; docker rm $2 ;
  docker rmi $3
}

start() {
  docker run -d --cap-add=NET_ADMIN --device=/dev/net/tun $1
}

id=`docker import - < $rootfs`
baseimage=meshbox-base-`echo $id | head -c 16`
docker tag $id $baseimage
sed -i "s/FROM .*/FROM $baseimage/" docker/Dockerfile
image=meshbox-`echo $id | head -c 16`
docker build --no-cache --force-rm -t $image docker/

containers[1]=$(start $image)
containers[2]=$(start $image)

trap "cleanup ${containers[1]} ${containers[2]} $image" EXIT

route() {
  docker exec -t $1 route -A inet6 | grep 'fc00::/8'
}

rt="$(route ${containers[1]})"
while [ -z "$rt" ] ; do sleep 1; rt="$(route ${containers[1]})"; done
rt="$(route ${containers[2]})"
while [ -z "$rt" ] ; do sleep 1; rt="$(route ${containers[2]})"; done
# setup ${containers[1]} smoketest0
# setup ${containers[2]} smoketest1

# This is the actual test, which makes sure that cjdns started correctly,
# and auto-peering is enabled. Fail if we don't receive a pong within 30 secs.
docker exec -t ${containers[1]} ping6 -w 30 -c 1 "$(ipv6addr ${containers[2]})" || exit 1
docker exec -t ${containers[2]} ping6 -w 30 -c 1 "$(ipv6addr ${containers[1]})" || exit 1
