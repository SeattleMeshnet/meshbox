meshbox
=======

This is the OpenWRT package feed for the [cjdns][cjdns] routing protocol. It provides OpenWrt integration and a web-based UI. Tested with OpenWRT Barrier Breaker (14.07) and Chaos Calmer (trunk).

![UI screenshot](https://github.com/SeattleMeshnet/meshbox/raw/ee9340a6421fe0342eda44b23028143923bb65ee/screenshot.png)

[meshbox]: http://fund.meshwith.me
[cjdns]: https://github.com/cjdelisle/cjdns


Installation
------------

We don't provide prebuilt packages yet (help welcome), so you'll have to build OpenWrt yourself. Integration into the OpenWRT buildroot is simple though.

    $ git clone git://git.openwrt.org/14.07/openwrt.git
    $ cd openwrt

    $ cp feeds.conf.default feeds.conf
    $ echo 'src-git meshbox git://github.com/seattlemeshnet/meshbox.git;for-14.07' >> feeds.conf
    $ ./scripts/feeds update -a
    $ ./scripts/feeds install -a

Then configure your firmware image: enable the luci-cjdns module, in addition to your usual settings, such as target system and profile. As usual, you'll need to hit space twice to make it `[*]` rather than `[M]`.

    $ make menuconfig
    LuCI -> Collections -> [*] luci
    LuCI -> Project Meshnet -> [*] luci-cjdns

Then build with `make`. You can append `-j $n`, where n is the number of CPU threads you want to use for compilation.

*Note:* The master branch is for development against OpenWrt Chaos Calmer (trunk). Unless you know what you're doing, you should always use OpenWrt Barrier Breaker (14.07), and the for-14.07 branch of Meshbox.


Contact
-------

- Issue tracker: [github.com/seattlemeshnet/meshbox/issues](https://github.com/seattlemeshnet/meshbox/issues)
- IRC: #cjdns on EFnet and [HypeIRC](https://wiki.projectmeshnet.org/HypeIRC)
- Mailing list: [cjdns-openwrt@lists.projectmesh.net](https://lists.projectmesh.net/pipermail/cjdns-openwrt/)
- Development updates: [www.lars.meshnet.berlin](http://www.lars.meshnet.berlin)


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

This will deploy `cjdns/files`, `cjdns/lua`, and `luci-cjdns/luasrc` to the appropriate directories in the container. If your changes require a restart, or the changed code is only run at boot time, you'll need to build your own image.

```
$ cd openwrt/
$ vim feeds.conf # src-git meshbox ... => src-link meshbox /path/to/meshbox
$ ./scripts/feeds update -a
$ ./feeds/meshbox/build-scripts/docker-image.sh
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
