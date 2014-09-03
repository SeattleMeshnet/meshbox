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

You can point the OpenWRT buildroot to a local meshbox clone by editing `<openwrt>/feeds.conf`:

    src-link meshbox /path/to/meshbox

If you want to use a local clone of cjdns itself as well, edit `<meshbox>/cjdns/Makefile`:

    PKG_SOURCE_URL:=file:///path/to/cjdns
    PKG_SOURCE_PROTO:=git
    PKG_SOURCE_VERSION:=master

You can then build a fresh package, that you can copy to the device, and then install. You need to delete the last clone everytime.

    rm dl/cjdns-*
    make package/cjdns/{clean,compile} V=s
    scp bin/<target>/packages/cjdns-*.ipkg root@<ip>:/tmp/cjdns.ipkg
    ssh root@<ip> 'opkg install /tmp/cjdns.ipkg'

Make sure to commit your changes to cjdns before building the package. The OpenWRT buildroot will clone the local cjdns into the build directory, omitting uncommitted changes.
