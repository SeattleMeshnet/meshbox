# You may redistribute this program and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
include $(TOPDIR)/rules.mk

PKG_NAME:=lua-cjdns
PKG_VERSION:=0.5-SNAPSHOT

PKG_SOURCE:=cjdns-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=cjdns-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/cjdelisle/cjdns.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
PKG_BUILD_DIR:=$(BUILD_DIR)/cjdns-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
CMAKE_OPTIONS += -DOPENWRT=1

# OpenWRT messes around with the code quite a bit and makes the codestyle validator angry.
CMAKE_OPTIONS += -DNO_CODESTYLE=1

# OpenWRT's NACL is not built position independent.
CMAKE_OPTIONS += -DWITH_PIE=0

# Need to tell cjdns build process that there exists an nacl on the system.
CMAKE_OPTIONS += -DHAVE_NACL=1

define Package/lua-cjdns
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua bindings for cjdns
  DEPENDS:=+cjdns +lua-bencode +dkjson +luasocket +lua-sha2
endef

define Package/lua-cjdns/description
  Lua bindings for cjdns
endef

define Package/lua-cjdns/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/common.lua \
		$(1)/usr/lib/lua/cjdns/common.lua

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/admin.lua \
		$(1)/usr/lib/lua/cjdns/admin.lua

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/config.lua \
		$(1)/usr/lib/lua/cjdns/config.lua

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/perm.lua \
		$(1)/usr/lib/lua/cjdns/perm.lua

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/router.lua \
		$(1)/usr/lib/lua/cjdns/router.lua

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/udp.lua \
		$(1)/usr/lib/lua/cjdns/udp.lua

	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/lua/cjdns/util.lua \
		$(1)/usr/lib/lua/cjdns/util.lua

endef

$(eval $(call BuildPackage,lua-cjdns))
