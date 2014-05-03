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
PKG_VERSION:=0.7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/cjdelisle/cjdns.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master

include $(INCLUDE_DIR)/package.mk

define Package/lua-cjdns
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua bindings for cjdns
  DEPENDS:=+cjdns +lua-bencode +dkjson +luasocket +lua-sha2
  MAINTAINER:=Igel
endef

define Build/Compile
endef

define Package/lua-cjdns/install
	$(INSTALL_DIR)	$(1)/usr/lib/lua/cjdns
	$(INSTALL_DATA)	$(PKG_BUILD_DIR)/contrib/lua/cjdns/*.lua 	$(1)/usr/lib/lua/cjdns
endef

$(eval $(call BuildPackage,lua-cjdns))
