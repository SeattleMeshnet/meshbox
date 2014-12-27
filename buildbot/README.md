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
7. TODO: Upload the Docker container to hub.docker.com

The GCC toolchain from previous smoketests of the same branch gets reused.
This decreases build runtime from about an hour to under 10 minutes. Packages
and firmware images, on the other hand, are always built with a fresh OpenWrt
clone and GCC toolchain.

## Automatic Updates

TODO

http://h.buildbot.meshwith.me/images/
http://h.buildbot.meshwith.me/packages/x86/

## Firmware Images and OPKG Repository

TODO

http://h.buildbot.meshwith.me/snapshots/x86/42/*sysupgrade*
http://h.buildbot.meshwith.me/snapshots/x86/42/*factory*
http://h.buildbot.meshwith.me/snapshots/x86/42/packages/meshbox/

## Notifications

There's a bot in HypeIRC/#openwrt that reports the outcome of each build.

## Setting up a Build Slave

for all builders:

- `apt-get install -y git mercurial subversion build-essential libncurses5-dev zlib1g-dev libssl-dev unzip`
- buildslave with `--umask=022`, so that artifacts are visible to the webserver

for smoketest:

- docker >= 1.3
- cjdns, with auto-peering on docker0
- the user that runs the buildslave needs to be in the docker group
- `apt-get install -y sudo qemu-utils`
- allow in /etc/sudoers: `/path/to/buildslave/smoketest/build/openwrt/feeds/meshbox/docker/make-tun.sh`
