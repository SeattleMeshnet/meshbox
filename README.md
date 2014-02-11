Copied from [cjdns-openwrt](https://github.com/cjdelisle/cjdns-openwrt)
This is an OpenWRT feed for the meshbox project.

To install meshbox on OpenWRT:

    $ cd ~
    $ svn co svn://svn.openwrt.org/openwrt/trunk/ openwrt
    $ cd openwrt
    $ cp ./feeds.conf.default ./feeds.conf
    $ echo 'src-git meshbox git@gitboria.com:finn/meshbox-openwrt.git' >> ./feeds.conf
    $ ./scripts/feeds update
    $ ./scripts/feeds install luci-cjdns

Then configure for your system:

    $ make menuconfig

Select your system type and the options you want and choose:

    Luci -> Project Meshnet -> [*] luci-cjdns

As usual, you'll need to hit space twice to make it `[*]` rather than `[M]`.

Then save and close the configuration menu, then allow OpenWRT to resolve dependencies:

    $ make defconfig

Then build:

    $ make

If you have a multicore processor, you can build faster using `-j`,
however the OpenWRT build process is not highly parallelized so your milage may vary.

    $ make -j 4

To update:

    $ ./scripts/feeds update
