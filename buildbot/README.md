# The Build Infrastructure

Our Buildbot instance takes care of Continuous Integration, prebuilt images,
automatic updates, and the OPKG repository, for the master branch (TODO: and
for-14.07 branch).

- on Hyperboria: <http://h.buildbot.meshwith.me>
- on Clearnet: <https://buildbot.meshwith.me>

If you want to donate a buildslave, please come to #openwrt on HypeIRC.

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
8. TODO: Peer between two containers instead of involving the host

The GCC toolchain from previous smoketests of the same branch gets reused.
This decreases build runtime from about an hour to under 10 minutes. Packages
and firmware images, on the other hand, are always built with a fresh OpenWrt
clone and GCC toolchain.

## Firmware Images and OPKG Repository

TODO

http://h.buildbot.meshwith.me/images/x86/
http://h.buildbot.meshwith.me/packages/x86/

## Automatic Updates

TODO

## Development snapshots

TODO

http://h.buildbot.meshwith.me/snapshots/x86/42/*sysupgrade*
http://h.buildbot.meshwith.me/snapshots/x86/42/*factory*
http://h.buildbot.meshwith.me/snapshots/x86/42/packages/meshbox/

## Notifications

There's a bot in HypeIRC/#openwrt that reports the outcome of each build.

TODO: on failure, it should blame the committer

## Setting up a Build Slave

There are builders for each of the targets, such as ar71xx, oxnas, x86. There is
an additional builder for the smoketest.

Requirements for all builders:

- `apt-get install -y git mercurial subversion build-essential autoconf libncurses5-dev zlib1g-dev libssl-dev unzip`
- buildslave with `--umask=022`, so that artifacts are visible to the webserver

Additional requirements for smoketest:

- docker >= 1.3 (kernel >= 3.8)
- the user that runs the buildslave needs to be in the docker group
- `apt-get install -y sudo qemu-utils`
- allow in /etc/sudoers: `/path/to/buildslave/smoketest/build/openwrt/feeds/meshbox/docker/make-tun.sh`
