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

PKG_NAME:=cjdns
PKG_VERSION:=0.6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
#PKG_SOURCE_URL:=http://gitboria.com/cjd/cjdns.git
#PKG_SOURCE_URL:=git://github.com/cjdelisle/cjdns.git
PKG_SOURCE_URL:=git://github.com/wfleurant/cjdns.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=master
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/cjdns
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Experimental self configuring routing protocol.
  DEPENDS:=+kmod-tun +kmod-ipv6 +libnl +libpthread +librt +jsonpath +libssp
  MAINTAINER:=cjd
endef

define Build/Configure
endef

# 	NO_PIE="TRUE" \

define Build/Compile
	CROSS="true" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CC="$(TARGET_CC)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	$(PKG_BUILD_DIR)/do
endef


define Package/cjdns/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cjdroute 	$(1)/usr/sbin/cjdroute
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/privatetopublic $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/publictoip6 	$(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/cjdns.config 		$(1)/etc/config/cjdns
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/cjdns.sh 		$(1)/etc/init.d/cjdns
	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_BIN) ./files/cjdroutesetup.lua 	$(1)/usr/share/cjdroutesetup.lua
	$(INSTALL_BIN) ./files/cjdns_jsonpath.sh	$(1)/usr/share/cjdns_jsonpath.sh
endef

$(eval $(call BuildPackage,cjdns))
