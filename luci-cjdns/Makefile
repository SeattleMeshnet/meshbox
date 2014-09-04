include $(TOPDIR)/rules.mk

PKG_NAME:=luci-cjdns
PKG_VERSION:=1.2
PKG_RELEASE:=1

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

define Package/luci-cjdns/install
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci ; \
  cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
endef

$(eval $(call BuildPackage,luci-cjdns))
