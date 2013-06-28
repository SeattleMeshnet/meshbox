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

PKG_NAME:=meshbox-ui
PKG_VERSION:=0.5-SNAPSHOT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git@gitboria.com:derp/meshbox-ui.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/meshbox-ui
  SECTION:=net
  CATEGORY:=Network
  #SUBMENU:=Routing and Redirection
  TITLE:=Experimental self configuring routing protocol.
  DEPENDS:=+kmod-tun +kmod-ipv6 +libnl +nacl +libpthread
  MAINTAINER:=thefinn93 -- #projectmeshnet on irc.efnet.org
endef


define Package/meshbox-ui/install
	$(INSTALL_DIR) $(1)/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/lib/lua/luci/view/*   $(1)/usr/lib/lua/luci/view/

endef

$(eval $(call BuildPackage,cjdns))
