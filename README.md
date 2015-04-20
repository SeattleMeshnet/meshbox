meshbox
=======

This is a collection of scripts used to build and test the [cjdns][cjdns] routing protocol.

[cjdns]: https://github.com/hyperboria/cjdns

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
$ cd openwrt/
$ ./scripts/feeds update -a
$ docker run -i -t meshbox /sbin/init
```

In case you want to make changes to cjdns itself, you can use CONFIG_SRC_TREE_OVERRIDE in OpenWrt menuconfig to build your local tree.

Make sure to commit your changes before building the package. The OpenWRT buildroot will then clone the local cjdns into the build directory, omitting uncommitted changes.

You can then build a fresh container including the changes to cjdns.
