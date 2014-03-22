#
# Copyright (C) 2009
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-cjdns
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Project Meshnet
  TITLE:=cjdns configuration for luci
  DEPENDS:=+cjdns +luci +dkjson +lua-bencode +lua-cjdns
endef

define Package/$(PKG_NAME)/description
  This package allows you to configure cjdns with luci
endef

define Build/Prepare
	for d in luasrc htdocs root; do \
	  if [ -d ./$$$$d ]; then \
	    mkdir -p $(PKG_BUILD_DIR)/$$$$d; \
		$(CP) ./$$$$d/* $(PKG_BUILD_DIR)/$$$$d/; \
	  fi; \
	done
endef


define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/config
  select BUSYBOX_CONFIG_SHA256SUM if !PACKAGE_coreutils-sha256sum
endef


HTDOCS = /www
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

define Package/$(PKG_NAME)/install
	if [ -d $(PKG_BUILD_DIR)/luasrc ]; then \
	  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
	  cp -pR $(PKG_BUILD_DIR)/luasrc/* $(1)$(LUCI_LIBRARYDIR)/; \
	else true; fi
	if [ -d $(PKG_BUILD_DIR)/htdocs ]; then \
	  $(INSTALL_DIR) $(1)$(HTDOCS); \
	  cp -pR $(PKG_BUILD_DIR)/htdocs/* $(1)$(HTDOCS)/; \
	else true; fi
	if [ -d $(PKG_BUILD_DIR)/root ]; then \
	  $(INSTALL_DIR) $(1)/; \
	  cp -pR $(PKG_BUILD_DIR)/root/* $(1)/; \
	else true; fi

	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_BIN) ./files/uci_to_cjdroute.lua 	$(1)/usr/share/uci_to_cjdroute.lua

endef

$(eval $(call BuildPackage,$(PKG_NAME)))

