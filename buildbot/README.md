# The Build Infrastructure

TODO:
- build cjdns changes
- pick repository based on sourcestamp
- build firewall and luci-app-firewall
- rewrite the readme
- deploy with docker

Our Buildbot instance takes care of Continuous Integration, prebuilt images,
automatic updates, and the OPKG repository, for the master and for-14.07 branches.

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
8. Peer between two containers instead of involving the host

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

http://h.buildbot.meshwith.me/snapshots/x86-master/42/*sysupgrade*
http://h.buildbot.meshwith.me/snapshots/x86-for-14.07/42/*factory*
http://h.buildbot.meshwith.me/snapshots/x86-master/latest/packages/meshbox/

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

- docker >= 1.3 (requires kernel >= 3.8)
- `apt-get install -y sudo qemu-utils`
- the user that runs the buildslave needs to be in the docker group
  - `usermod -G docker buildbot`
  - `groups buildbot # => buildbot : buildbot docker`
  - make sure you re-login before starting the buildslave
- allow in /etc/sudoers: `/path/to/buildslave/$builderName/build/openwrt/feeds/meshbox/docker/make-tun.sh`
  - possible values of $builderName are `cc-smoketest` and `bb-smoketest`
