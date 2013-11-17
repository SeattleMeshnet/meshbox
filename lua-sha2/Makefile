#
# Copyright (C) 2013 Seattle Meshnet
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-sha2
PKG_REV:=02bd4bfdc806
PKG_VERSION:=$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_REV).tar.gz
PKG_SOURCE_URL:=https://code.google.com/p/sha2/
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
include $(INCLUDE_DIR)/package.mk

define Package/lua-sha2
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua binding for the SHA-256/384/512
  URL:=https://code.google.com/p/sha2/
  DEPENDS:=+lua
endef

define Package/lua-sha2/description
  Lua binding for the SHA-256/384/512 BSD-licensed C implementation by Aaron Gifford
  http://www.aarongifford.com/computers/sha.html
endef

define Build/Configure
  
endef

define Build/Compile
endef


define Package/lua-sha2/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hmac.lua	$(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hmac/sha2.lua 	$(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hmac/md5.lua 	$(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-sha2))
