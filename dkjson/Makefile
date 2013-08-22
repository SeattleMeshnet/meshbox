#
# Copyright (C) 2013 Seattle Meshnet
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dkjson
PKG_REV:=f1ec467af341e120
PKG_VERSION:=$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_REV).tar.gz
PKG_SOURCE_URL:=http://dkolf.de/src/dkjson-lua.fsl/tarball/dkjson-f1ec467af341e120.tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

include $(INCLUDE_DIR)/package.mk

define Package/dkjson
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=DKJSON
  URL:=http://dkolf.de/src/dkjson-lua.fsl/home
  DEPENDS:=+lua
endef

define Package/dkjson/description
  This is a JSON module written in Lua. It supports UTF-8.
endef

define Build/Configure
endef

define Build/Compile
endef


define Package/dkjson/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) ./dkjson.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,dkjson))
