#!/bin/sh
SRC="git://git.openwrt.org/openwrt.git"

# local downloads
# DL="/usr/src/openwrt/dl"

use_hype_src=

TARGET="ar71xx"

[ "$1" ] && TARGET="$1"
[ "$2" ] && SUBTARGET="$2"
[ "$3" ] && PROFILE="$3"


git clone "$SRC" "openwrt-${TARGET}"

cd "openwrt-${TARGET}"

[ "$DL" ] && [ ! -e dl ] && ln -s "$DL" dl

echo "CONFIG_TARGET_${TARGET}=y" >./.config
[ "$SUBTARGET" ] && echo "CONFIG_TARGET_${TARGET}_${SUBTARGET}=y" >> ./.config
[ "$PROFILE" ] && if [ "$SUBTARGET" ]; then
	echo "CONFIG_TARGET_${TARGET}_${SUBTARGET}_${PROFILE}=y" >> ./.config
else
	echo "CONFIG_TARGET_${TARGET}_${PROFILE}=y" >> ./.config
fi

cat <<EOF >>./.config
CONFIG_SDK=y
CONFIG_IMAGEOPT=y
CONFIG_VERSION_DIST="meshbox"
CONFIG_VERSION_REPO="http://downloads.openwrt.org/snapshots/trunk/%S/packages"
CONFIG_IB=y
CONFIG_DEVEL=y
CONFIG_SRC_TREE_OVERRIDE=y
CONFIG_TOOLCHAINOPTS=y
CONFIG_LIBC_USE_MUSL=y
# CONFIG_LIBC_USE_UCLIBC is not set
# CONFIG_LIBC_USE_GLIBC is not set
CONFIG_KERNEL_SECCOMP=y
CONFIG_PKG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_PKG_CC_STACKPROTECTOR_NONE is not set
CONFIG_KERNEL_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_KERNEL_CC_STACKPROTECTOR_NONE is not set
# CONFIG_PKG_FORTIFY_SOURCE_NONE is not set
CONFIG_PKG_FORTIFY_SOURCE_1=y
# CONFIG_PKG_FORTIFY_SOURCE_2 is not set
# CONFIG_PKG_RELRO_NONE is not set
CONFIG_PKG_RELRO_PARTIAL=y
# CONFIG_PKG_RELRO_FULL is not set
CONFIG_PKG_CHECK_FORMAT_SECURITY=y
CONFIG_PACKAGE_kmod-ipv6=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_cjdns=y
EOF

make defconfig

make


