include $(TOPDIR)/rules.mk

PKG_NAME:=luci-cjdns
PKG_RELEASE:=1.0.1

include $(INCLUDE_DIR)/package.mk

define Package/luci-cjdns
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Project Meshnet
  TITLE:=cjdns configuration for luci
  DEPENDS:=+cjdns +luci-base
endef

define Package/luci-cjdns/description
  This package allows you to configure cjdns with luci
endef

define Build/Compile
endef

LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

define Package/luci-cjdns/install
  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
  cp -pR ./luasrc/* $(1)$(LUCI_LIBRARYDIR)
endef

$(eval $(call BuildPackage,luci-cjdns))
