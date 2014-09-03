meshbox
=======

This is the OpenWRT package feed for the [meshbox][meshbox] project. It provides UCI and LuCI integration for [cjdns][cjdns]. Tested with OpenWRT Barrier Breaker (14.07) and Chaos Calmer (trunk).

[meshbox]: http://fund.meshwith.me
[cjdns]: https://github.com/cjdelisle/cjdns

Integration into the OpenWRT buildroot is simple.

    $ git clone git://git.openwrt.org/14.07/openwrt.git
    $ cd openwrt

    $ cp feeds.conf.default feeds.conf
    $ echo 'src-git meshbox git://github.com/seattlemeshnet/meshbox.git' >> feeds.conf
    $ ./scripts/feeds update
    $ ./scripts/feeds install luci-cjdns

Then configure your firmware image: enable the luci-cjdns module, in addition to your usual settings, such as target system and profile. As usual, you'll need to hit space twice to make it `[*]` rather than `[M]`.

    $ make menuconfig
    LuCI -> Collections -> [*] luci
    LuCI -> Project Meshnet -> [*] luci-cjdns

Then save and close the configuration menu, and allow OpenWRT to resolve dependencies:

    $ make defconfig

Then build:

    $ make

If you have a multicore processor, you can build faster using `-j`, however the OpenWRT build process is not highly parallelized so your milage may vary.

    $ make -j 4

To update:

    $ ./scripts/feeds update


Development
-----------

Almost all of the development can be conducted using only a Docker container.

```
$ docker run -i -t lgierth/meshbox /sbin/init
> printf "12345\n12345\n" | passwd
> ifconfig eth0 | grep 'inet addr'
>
```

Then you can code away, and deploy the changed files as needed.

```
$ build-scripts/deploy.sh root@ADDRESS 12345
```

This will deploy `cjdns/files`, `cjdns/lua`, and `luci-cjdns/luasrc` to the appropriate directories in the container. If your changes require a restart, or the changed code is only run at boot time, you'll need to build your own image. Add, update, and install the meshbox feed according to the instructions above, then build and run the image.

```
$ cd openwrt/
$ feeds/meshbox/build-scripts/docker-image.sh
$ docker run -i -t meshbox /sbin/init
```

In case you want to make changes to cjdns itself, you can modify `<meshbox>/cjdns/Makefile` to use a local clone of cjdns.

```
PKG_SOURCE_URL:=file:///path/to/cjdns
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
```

Make sure to commit your changes to cjdns before building the package. The OpenWRT buildroot will clone the local cjdns into the build directory, omitting uncommitted changes.

You can then build a fresh container including the changes to cjdns.
