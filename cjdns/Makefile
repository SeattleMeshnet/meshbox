include $(TOPDIR)/rules.mk

PKG_NAME:=cjdns
PKG_VERSION:=0.7.3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/berlinmeshnet/cjdns.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f7780d847102b54f5c51dbdaac76db15a91ae70b
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/cjdns
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Experimental self configuring routing protocol.
  DEPENDS:=+kmod-tun +kmod-ipv6 +libnl-tiny +libpthread +librt +SSP_SUPPORT:libssp \
		+lua-bencode +dkjson +luasocket +lua-sha2
  MAINTAINER:=cjd
endef

define Build/Configure
endef

define Build/Compile
	CROSS="true" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CC="$(TARGET_CC)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	TARGET_ARCH="$(CONFIG_ARCH)" \
	SSP_SUPPORT="$(CONFIG_SSP_SUPPORT)" \
	UCLIBC=1 \
	Seccomp_NO=1 \
	$(PKG_BUILD_DIR)/do
endef

define Package/cjdns/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/cjdrouteconf $(1)/usr/bin/cjdrouteconf
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cjdroute 	$(1)/usr/sbin/cjdroute
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/privatetopublic $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/publictoip6 	$(1)/usr/sbin/
	# $(INSTALL_BIN) $(PKG_BUILD_DIR)/build_linux/testcjdroute $(1)/usr/sbin/
	# $(INSTALL_BIN) $(PKG_BUILD_DIR)/dnsserv 	$(1)/usr/sbin/dnsserv
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/cjdns 	$(1)/etc/init.d/cjdns
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/cjdns $(1)/etc/uci-defaults/cjdns
	$(INSTALL_DIR)	$(1)/usr/lib/lua/cjdns
	$(INSTALL_DATA)	$(PKG_BUILD_DIR)/contrib/lua/cjdns/*.lua $(1)/usr/lib/lua/cjdns/
	$(INSTALL_DATA) ./lua/cjdns/*.lua $(1)/usr/lib/lua/cjdns/

	$(INSTALL_DIR) $(1)/CONTROL
	$(INSTALL_DATA) ./ipkg/* $(1)/CONTROL/
endef

$(eval $(call BuildPackage,cjdns))
