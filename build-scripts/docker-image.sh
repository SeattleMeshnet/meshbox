#!/bin/bash

set +ex

# Used to produce the prebuilt image at lgierth/meshbox
#
# docker run -i -t lgierth/meshbox /sbin/init

rm .config
make defconfig
echo CONFIG_TARGET_x86=y >> .config
#echo CONFIG_TARGET_x86_Default=y >> .config
echo CONFIG_TARGET_ROOTFS_TARGZ=y >> .config
echo CONFIG_PACKAGE_luci=y >> .config
echo CONFIG_PACKAGE_luci-cjdns=y >> .config
#echo CONFIG_PACKAGE_netperf=y >> .config
#echo CONFIG_PACKAGE_tcpdump=y >> .config
#echo CONFIG_PACKAGE_ip=y >> .config
#echo CONFIG_PACKAGE_mtr=y >> .config
#echo CONFIG_PACKAGE_iputils-ping=y >> .config
#echo CONFIG_PACKAGE_iputils-tracepath=y >> .config
#echo CONFIG_PACKAGE_iputils-ping6=y >> .config
#echo CONFIG_PACKAGE_iputils-tracepath6=y >> .config
#echo CONFIG_PACKAGE_iputils-traceroute6=y >> .config
make defconfig

make -j 3
docker import - meshbox < bin/x86/openwrt-x86-generic-Generic-rootfs.tar.gz
