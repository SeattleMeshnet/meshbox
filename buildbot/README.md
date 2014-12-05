# The Build Infrastructure

Our Buildbot instance takes care of Continuous Integration, Automatic Updates,
and the OPKG repository, for both the master and for-14.07 branches.

- on Clearnet: <https://buildbot.meshwith.me>
- on Hyperboria: <http://h.buildbot.meshwith.me>

This document assumes that you are familiar with [Buildbot's concepts][concepts],
specifically Build, Builder, BuildSlave, and Scheduler.

[concepts]: http://docs.buildbot.net/latest/manual/concepts.html

## Continuous Integration

For every commit we run a minimal test suite called the smoketest. It consists
of the following steps.

1. Compile an x86 rootfs image
2. Start a Docker container using this image
3. Create a TUN interface and attach it to the container
4. Peer cjdns in the container with cjdns on the host
5. Wait for one successful ping from host to container, or fail after 30 seconds
6. TODO: Check if the host is listed under "Active peers" in LuCI

Build artifacts, e.g. packages or firmware images, are discarded.

The GCC toolchain from previous smoketests of the same branch gets reused.
This decreases build runtime from about an hour to under 10 minutes. Packages
and firmware images, on the other hand, are always built with a fresh OpenWrt
clone and GCC toolchain.

## Automatic Updates

TODO

http://h.buildbot.meshwith.me/updates/

## Firmware Images and OPKG Repository

TODO

http://h.buildbot.meshwith.me/snapshots/x86/*sysupgrade*
http://h.buildbot.meshwith.me/snapshots/x86/*factory*
http://h.buildbot.meshwith.me/snapshots/x86/packages/

## Notifications

There's a bot in HypeIRC/#openwrt that reports the outcome of each build.

## Setting up a Build Slave

git mercurial subversion build-essential libncurses5-dev zlib1g-dev libssl-dev unzip

for x86 and smoketest:

- docker >= 1.3
- sudo
- allow in /etc/sudoers: /path/to/buildslave/smoketest-*/build/feeds/meshbox/docker/make-tun.sh
- qemu-utils
