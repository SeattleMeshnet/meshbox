cjdns on OpenWrt
================

> \<@larsg> it's essentially: get an openwrt 15.05 image fitting your hardware, then `opkg update && opkg install luci-app-cjdns`

If you want to give cjdns on OpenWrt a try, see the quote above. This repository contains tools for testing and development.

This is a collection of scripts used to build and test the [cjdns][cjdns] routing protocol with [OpenWrt][OpenWrt] and/or inside [Docker.io][Docker.io].

[cjdns]: https://github.com/hyperboria/cjdns
[OpenWrt]: https://www.openwrt.org/
[Docker.io]: https://www.docker.io/

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
$ ./deploy.sh root@ADDRESS 12345
```

This will deploy `cjdns/files`, `cjdns/lua`, and `luci-app-cjdns/luasrc` to the appropriate directories in the container. If your changes require a restart, or the changed code is only run at boot time, you'll need to build your own image.

```
$ git clone git://git.openwrt.org/openwrt.git
$ cd openwrt/
$ ./scripts/feeds update -a
$ ./scripts/feeds install luci-app-cjdns
$ make menuconfig ; # select the x86_64 target to build stuff for Docker
$ make
$ docker run -i -t meshbox /sbin/init
```

In case you want to make changes to cjdns itself, you can use CONFIG_SRC_TREE_OVERRIDE in OpenWrt menuconfig to build your local tree.

Make sure to commit your changes before building the package. The OpenWRT buildroot will then clone the local cjdns into the build directory, omitting uncommitted changes.

You can then build a fresh container including the changes to cjdns.
