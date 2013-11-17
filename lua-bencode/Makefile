#
# Copyright (C) 2013 Seattle Meshnet
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-bencode
PKG_REV:=b0e183bb3f3d6970d0f2472cd65e5b8bb110e487
PKG_VERSION:=0.3_r$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://bitbucket.org/wilhelmy/lua-bencode
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=hg

include $(INCLUDE_DIR)/package.mk

define Package/lua-bencode
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua Bencode
  URL:=https://bitbucket.org/wilhelmy/lua-bencode
  DEPENDS:=+lua
endef

define Package/lua-bencode/description
  This is a module for the lua programming language for decoding and encoding
  bencoded data which can be used to read and write torrent files for bittorrent.
endef

define Build/Configure
endef

define Build/Compile
endef


define Package/lua-bencode/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/bencode.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-bencode))
