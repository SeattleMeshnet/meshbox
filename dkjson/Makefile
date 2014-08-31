include $(TOPDIR)/rules.mk

PKG_NAME:=dkjson

PKG_VERSION:=master
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/LuaDist/dkjson.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_VERSION:=master

include $(INCLUDE_DIR)/package.mk

define Package/dkjson
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=DKJSON
  URL:=http://dkolf.de/src/dkjson-lua.fsl/home
  MAINTAINER:=Lars Gierth <larsg@systemli.org>
  DEPENDS:=+lua
endef

define Package/dkjson/description
  Lua JSON parser/serializer with UTF-8 support
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/dkjson/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(BUILD_DIR)/dkjson/dkjson.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,dkjson))
