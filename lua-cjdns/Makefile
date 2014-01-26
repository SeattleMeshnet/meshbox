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

include $(INCLUDE_DIR)/package.mk

define Package/lua-cjdns
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua bindings for cjdns
  DEPENDS:=+cjdns +lua-bencode +dkjson +luasocket
endef

define Package/lua-cjdns/description
  Lua bindings for cjdns
endef

define Build/Configure
endef

define Build/Compile
endef



define Package/lua-cjdns/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/common.lua 	$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/admin.lua 	$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/config.lua 	$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/perm.lua 		$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/router.lua 	$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/udp.lua 		$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/util.lua 		$(1)/usr/lib/lua/cjdns

	$(INSTALL_DATA) ./files/cjdns/init.lua 		$(1)/usr/lib/lua/cjdns

endef

$(eval $(call BuildPackage,lua-cjdns))
